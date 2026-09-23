require "google/cloud/bigquery"
require "tempfile"
require "json"
require "time"

module BigQuery
  # Syncs an Enumerable of rows into a BigQuery table, so its contents end up matching the
  # source. Rows are matched on the `key` columns: rows only in the source are inserted, rows
  # only in the table are deleted, and rows in both whose values differ are updated.
  #
  # The changes are applied as two jobs (a DELETE, then an append load), not atomically. An
  # update is a delete of the old row followed by an insert of the new one, so if the load
  # fails the updated rows are missing until the next sync puts them back.
  module TableSync
    class EmptySourceError < StandardError; end

    class << self
      def call(dataset:, table:, key:, rows:)
        source = index_by_key(rows.to_a, key)
        raise EmptySourceError, "no rows to sync for #{table}" if source.empty?

        existing = index_by_key(existing_rows(dataset, table), key)

        inserts = source.except(*existing.keys)
        deletes = existing.except(*source.keys)
        updates = source.slice(*existing.keys).reject { |row_key, row| same_row?(row, existing[row_key]) }

        delete_rows(dataset, table, key, deletes.keys + updates.keys)
        append_rows(dataset, table, inserts.values + updates.values)
      end

      private

      def existing_rows(dataset, table)
        return [] unless dataset.table(table)

        dataset.query("SELECT * FROM `#{table}`").all.to_a
      end

      def index_by_key(rows, key)
        rows.index_by { |row| row_key(row, key) }
      end

      # Stringified so an INTEGER column read back from BigQuery (123) matches the string the
      # source sent ("123"). Serialised the same way as the TO_JSON_STRING in #delete_rows.
      def row_key(row, key)
        key.map { |column| row[column]&.to_s }.to_json
      end

      # Only the source's columns are compared, and values are normalised first, because
      # BigQuery hands back typed values (Integer, Time) for what the source sends as strings.
      def same_row?(source_row, existing_row)
        source_row.all? { |column, value| normalise(value) == normalise(existing_row[column]) }
      end

      def normalise(value)
        return value.to_time.utc if value.respond_to?(:to_time) && !value.is_a?(String)
        return nil if value.nil? || value == ""

        begin
          Time.iso8601(value.to_s).utc
        rescue ArgumentError
          value.to_s
        end
      end

      def delete_rows(dataset, table, key, row_keys)
        return if row_keys.empty?

        key_sql = key.map { |column| "CAST(#{column} AS STRING)" }.join(", ")
        dataset.query(
          "DELETE FROM `#{table}` WHERE TO_JSON_STRING([#{key_sql}]) IN UNNEST(@row_keys)",
          params: { row_keys: row_keys },
        )
      end

      def append_rows(dataset, table, rows)
        return if rows.empty?

        with_ndjson_file(rows) do |file|
          dataset.load(table, file, format: "json", write: "append", autodetect: true)
        end
      end

      # BigQuery's load only accepts a real file (or a Cloud Storage reference), not an
      # in-memory string, so the rows are written out as newline-delimited JSON first.
      def with_ndjson_file(rows)
        file = Tempfile.new(["table_sync", ".json"])
        rows.each { |row| file.puts(row.to_json) }
        file.rewind

        yield file
      ensure
        file&.close
        file&.unlink
      end
    end
  end
end
