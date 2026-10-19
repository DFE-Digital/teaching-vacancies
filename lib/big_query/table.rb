require "google/cloud/bigquery"
require "tempfile"
require "json"

module BigQuery
  # A BigQuery table that is replaced wholesale on each write. Nothing is read back, so the
  # service account never needs access to the policy-tagged columns it writes, which it is not
  # allowed to read.
  #
  # `schema` is called with the load job's schema to define the columns.
  class Table
    attr_reader :name, :schema

    def initialize(name, schema:, dataset: nil)
      @name = name
      @schema = schema
      @dataset = dataset
    end

    # One load job that truncates and refills the table, so the swap is atomic: if the load
    # fails, the table keeps what it held before. The load's schema replaces the table's, and
    # a load job rather than a streaming insert means a bad row fails the load instead of
    # being silently dropped. Refuses an empty load rather than emptying the table.
    def replace(rows)
      raise ArgumentError, "refusing to replace #{name} with no rows" if rows.empty?

      with_ndjson_file(rows) do |file|
        dataset.load(name, file, format: "json", write: "truncate", create: "needed", &schema)
      end
    end

    private

    # Looked up on first use, so a Table can be built without connecting to BigQuery.
    def dataset
      @dataset ||= Google::Cloud::Bigquery.new.dataset(Rails.configuration.bigquery_dataset)
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
