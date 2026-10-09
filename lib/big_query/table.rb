require "google/cloud/bigquery"
require "tempfile"
require "json"

module BigQuery
  # A BigQuery table, as BigQuery::TableSync reads and writes it: every row, deleting rows and
  # appending rows. This is the only place that knows how those are done in BigQuery, so
  # TableSync can be given any object with the same methods.
  #
  # `key` is the columns that identify a row, which #delete matches rows on. `schema` is called
  # with the load job's schema to define the columns, and is used when #insert creates the
  # table.
  class Table
    attr_reader :name, :key, :schema

    def initialize(name, key:, schema:, dataset: nil)
      @name = name
      @key = key
      @schema = schema
      @dataset = dataset
    end

    # Read through the API, so no SQL is needed. A table that doesn't exist yet has no rows;
    # #insert creates it.
    def rows
      table = dataset.table(name)
      return [] if table.nil?

      table.data.all
    end

    def delete(rows)
      return if rows.empty?

      dataset.query(
        "DELETE FROM `#{name}` WHERE #{key_sql} IN UNNEST(@row_keys)",
        params: { row_keys: rows.map { |row| row_key(row) } },
      )
    end

    # A load job rather than a streaming insert (dataset.insert): BigQuery can't DELETE rows
    # still in the streaming buffer, which would make the next sync fail.
    def insert(rows)
      return if rows.empty?

      with_ndjson_file(rows) do |file|
        dataset.load(name, file, format: "json", write: "append", create: "needed", &schema)
      end
    end

    private

    # Looked up on first use, so a Table can be built without connecting to BigQuery.
    def dataset
      @dataset ||= Google::Cloud::Bigquery.new.dataset(Rails.configuration.bigquery_dataset)
    end

    # A row's key columns, serialised the way BigQuery's TO_JSON_STRING serialises #key_sql,
    # so the two compare equal. A nil stays nil (JSON null, as BigQuery serialises a NULL),
    # because nil.to_s is "", which would stop a row with a NULL key column ever matching.
    def row_key(row)
      key.map { |column| row.fetch(column)&.to_s }.to_json
    end

    def key_sql
      "TO_JSON_STRING([#{key.map { |column| "CAST(#{column} AS STRING)" }.join(', ')}])"
    end

    # BigQuery's load only accepts a real file (or a Cloud Storage reference), not an
    # in-memory string, so the rows are written out as newline-delimited JSON first.
    # Tempfile.create closes and deletes the file when the block exits, even on error.
    def with_ndjson_file(rows)
      Tempfile.create([name, ".json"]) do |file|
        rows.each { |row| file.puts(row.to_json) }
        file.rewind

        yield file
      end
    end
  end
end
