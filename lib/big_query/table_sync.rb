require "google/cloud/bigquery"
require "tempfile"
require "json"

module BigQuery
  # Syncs an Enumerable of rows into a BigQuery table, so its contents end up matching the
  # source. Rows are matched on the `key` columns: rows only in the source are inserted, rows
  # only in the table are deleted, and rows in both are replaced only if their values differ.
  # An empty source empties the table.
  #
  # The changes are applied as two jobs (a DELETE, then an append load), not atomically. A
  # changed row is deleted and then loaded again, so if the load fails the changed rows are
  # missing until the next sync puts them back.
  module TableSync
    class << self
      def call(table:, key:, rows:)
        dataset = Google::Cloud::Bigquery.new.dataset(Rails.configuration.bigquery_dataset)
        source = rows.index_by { |row| row_key(row, key) }
        stale_keys, fresh_rows = changes(source, existing_rows(dataset, table, key))

        delete_rows(dataset, table, key, stale_keys) if stale_keys.any?
        append_rows(dataset, table, fresh_rows) if fresh_rows.any?
      end

      private

      # The keys of the table rows to delete (removed or changed), and the source rows to load
      # (added or changed).
      def changes(source, existing)
        removed_keys = existing.keys - source.keys
        added_keys = source.keys - existing.keys
        changed_keys = (existing.keys & source.keys).reject { |row_key| same_row?(existing[row_key], source[row_key]) }

        [removed_keys + changed_keys, source.values_at(*added_keys, *changed_keys)]
      end

      # A missing table raises Google::Cloud::NotFoundError here, rather than being created.
      #
      # BigQuery returns a query's results a page (a batch of rows) at a time, and the query
      # result only holds the first batch. Data#all fetches the remaining batches from BigQuery
      # as it is iterated.
      def existing_rows(dataset, table, key)
        dataset.query("SELECT #{key_sql(key)} AS row_key, * FROM `#{table}`").all.index_by { |row| row[:row_key] }
      end

      def same_row?(stored_row, sent_row)
        sent_row.all? { |column, sent| same_value?(stored_row[column], sent) }
      end

      # BigQuery hands values back typed by the table's schema, which its load autodetected
      # from the strings the source sent: an ISO 8601 string is stored as a TIMESTAMP and
      # comes back as a Time, "123" is stored as an INTEGER and comes back as 123.
      def same_value?(stored, sent)
        case stored
        when Time then Time.zone.parse(sent.to_s) == stored
        else stored&.to_s == sent&.to_s
        end
      end

      # Stringified so an INTEGER column in BigQuery (123) matches the string the source sent
      # ("123"). Serialised to match #key_sql, so keys built here and in BigQuery compare equal.
      # A nil stays nil (JSON null, as BigQuery serialises a NULL), because nil.to_s is "",
      # which would stop a row with a NULL key column ever matching.
      def row_key(row, key)
        key.map { |column| row.fetch(column)&.to_s }.to_json
      end

      def key_sql(key)
        "TO_JSON_STRING([#{key.map { |column| "CAST(#{column} AS STRING)" }.join(', ')}])"
      end

      def delete_rows(dataset, table, key, row_keys)
        dataset.query(
          "DELETE FROM `#{table}` WHERE #{key_sql(key)} IN UNNEST(@row_keys)",
          params: { row_keys: row_keys },
        )
      end

      def append_rows(dataset, table, rows)
        with_ndjson_file(rows) do |file|
          dataset.load(table, file, format: "json", write: "append", autodetect: true)
        end
      end

      # BigQuery's load only accepts a real file (or a Cloud Storage reference), not an
      # in-memory string, so the rows are written out as newline-delimited JSON first.
      # Tempfile.create closes and deletes the file when the block exits, even on error.
      def with_ndjson_file(rows)
        Tempfile.create(["table_sync", ".json"]) do |file|
          rows.each { |row| file.puts(row.to_json) }
          file.rewind

          yield file
        end
      end
    end
  end
end
