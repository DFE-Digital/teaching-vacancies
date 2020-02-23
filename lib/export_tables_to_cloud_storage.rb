require 'fileutils'
require 'google/cloud/bigquery'
require 'google/cloud/storage'
require 'rollbar'

class ExportTablesToCloudStorage
  include Google::Cloud

  # The maximum number of bad records BigQuery will allow before raising an error.
  BAD_RECORDS = 20.freeze
  BAD_RECORD_RATE = 0.005.freeze

  BIGQUERY_DATASET = ENV.fetch('GOOGLE_BIGQUERY_DATASET').freeze
  BUCKET = ENV.fetch('GOOGLE_CLOUD_STORAGE_BUCKET').freeze

  # Skip attributes that cannot be queried, we do not report on or that frequently break the import.
  # Drop gias_data because it is aliased to data. This alias allows all records to be handled the same way and dropping
  # gias_data removes duplication of data.
  DROP_THESE_ATTRIBUTES = %w[
    education
    experience
    gias_data
    job_description
    qualifications
    supporting_documents
    weekly_hours
  ].freeze

  EXCLUDE_TABLES = %w[
    activities
    ar_internal_metadata
    friendly_id_slugs
    schema_migrations
    sessions
  ].freeze

  # This ensures that new tables are automatically added to the BigQuery dataset.
  #
  # `#singularize` must come *after* `#camelize` in `#map` for the AuditData inflection rule to work correctly. The
  # inflector wasn't correctly picking up the snake cased version.
  TABLES = ApplicationRecord.connection.tables
    .reject { |table| EXCLUDE_TABLES.include?(table) }
    .sort
    .map { |table| table.camelize.singularize }
    .freeze

  BATCH_SIZE = 1000

  attr_reader :bad_records, :bucket, :data_field_normalizer, :dataset, :runtime, :tmpdir

  def initialize(bigquery: Bigquery.new, storage: Storage.new)
    @bad_records = {}
    @bucket = storage.bucket(BUCKET)
    @data_field_normalizer = {}
    @dataset = bigquery.dataset(BIGQUERY_DATASET)
    @runtime = DateTime.now.to_s(:db).parameterize
    @tmpdir = Dir.mktmpdir
  end

  def run!
    export
    upload_to_google_cloud_storage
    load_to_bigquery
    FileUtils.rm_rf(Rails.root.join(tmpdir))
  end

  private

  def export
    logging_details = { phase: 'local export' }
    TABLES.each do |table|
      file = Rails.root.join(tmpdir, "#{table.underscore}.json")

      logging_details = logging_details.merge({
        outfile: file,
        table: table
      })

      Rails.logger.info(logging_details.to_json)

      # This permits selective re-runs without needing to overwrite everything.
      # Mostly to be used from the REPL or scripts
      if File.exist?(file)
        logging_details[:exists] = 'skipping'
        Rails.logger.info(logging_details.to_json)
        next
      end

      fh = File.new(file, 'w')

      records = table.constantize
      total_records = records.count
      logging_details = logging_details.merge({
        record_count: total_records,
        records_processed: 0
      })

      bad_records["#{table.underscore}.json"] = (total_records * BAD_RECORD_RATE).to_i

      next if records.none?

      analyze_data_field(records, table.to_s) if records.all.first.respond_to?(:data)

      records.find_in_batches(batch_size: BATCH_SIZE) do |batch|
        batch.each do |row|
          fh.puts clean_record(row, table.to_s).to_json
        end
        logging_details[:records_processed] += batch.size
        Rails.logger.info(logging_details.to_json)
      end
      fh.close
    end

    Rails.logger.info(logging_details.to_json)
  end

  # Ensure that all records have a consistent map of the data keys. This is to prevnet BigQuery breaking when importing
  # records with flattened json columns that have differing numbers of attributes. This is a tradeoff between runtime
  # and maintainability.
  #
  # TODO: This would be much more sensibly done in an `#as_json` method on each model. However, we have a lot of models
  # and some dependencies that are not immediately obvious-like the RESTFUL API endpoints. It would be easy to break
  # something by doing so. Until we've got more time to refactor this is the safer approach. That said, even that
  # approach would have to traverse all the records to make sure it had captured the whole schema.
  def analyze_data_field(records, table_name)
    logging_details = {
      phase: 'json analysis',
      record_count: records.count,
      records_analyzed: 0,
      table: table_name,
    }

    Rails.logger.info(logging_details.to_json)
    records_missing_data = []
    data_field_normalizer[table_name] = SortedSet.new()
    records.find_in_batches(batch_size: BATCH_SIZE) do |batch|
      batch.each do |row|
        if row.data.respond_to?(:keys)
          data_field_normalizer[table_name].merge(row.data.keys)
        else
          records_missing_data << row.id
        end
      end
      logging_details[:records_analyzed] += batch.size
      Rails.logger.info(logging_details.to_json)
    end

    logging_details = logging_details.merge({
      records_missing_data: records_missing_data,
      records_missing_data_count: records_missing_data.size
    })
    Rails.logger.info(logging_details.to_json)
  end

  def clean_record(record, table_name)
    scratch = {}
    record.as_json.keys.each { |key|
      if record.class.columns_hash[key].type == :datetime || record.class.columns_hash[key].type == :date
        # BigQuery uses the same standard format for dates and datetimes that `.to_s(:db)` outputs.
        if record[key].blank?
          scratch[key] = nil
        else
          scratch[key] = record[key].to_s(:db)
        end
      elsif key.match?(/data/) # Flatten the data structure into one level
        if record.data.respond_to?(:keys)
          data_field_normalizer[table_name].each do |normalized_key|
            value = record.data[normalized_key]

            # Dates are the only values in gias data that can be cast without running in to trouble with variations in
            # the data. BigQuery already does this intelligently with every other column type. Miscast values are
            # *sometimes* raised by BigQuery as errors (see next paragraph) and can be ignored if there are staistically
            # insignificant numbers of them.
            #
            # Review the values on `data_Diocese_code` for a typical example - most are postcode-like strings, while a
            # some are two or three digits numbers. Despite the presence of the two and three digit numbers, BigQuery
            # sets the column type as sting and seems to be able to coerce the number-only values into strings. It does
            # not do this reliably on every column of every table, however; it failed to coerce some larger numbers on
            # the `School#address3` for example. That said, there are less than ten of these at the time of commit.
            #
            value = Date.parse(value).to_s(:db) if (value.is_a?(String) && value.match?(/^\d{2}\-\d{2}\-\d{4}$/))
            # I didn't use `#parameterize(separator: '_')` here because it is **SLOW** in contrast to this.
            scratch["data_#{normalized_key.chomp(')').gsub(/\W+/, '_')}"] = value.presence
          end
        else
          data_field_normalizer[table_name].each do |normalized_key|
            scratch["data_#{normalized_key.chomp(')').gsub(/\W+/, '_')}"] = nil
          end
        end
      elsif DROP_THESE_ATTRIBUTES.include?(key)
        # noop - skip attributes that cannot be queried, we do not report on or that frequently break the import.
      else
        value = record[key]
        value = value.to_f if value.is_a?(String) && value.match(/^(\d|\.)+$/)
        value = value.to_i if value.is_a?(String) && value.match(/^(\d)+$/)
        scratch[key] = value.presence
      end
    }
    scratch
  end

  def upload_to_google_cloud_storage
    logging_details = { phase: 'upload to cloud storage' }
    Dir.children(tmpdir).each do |file|
      bucket_path = "json_export/#{runtime}/#{file}"
      local_path = Rails.root.join(tmpdir, file)
      logging_details = logging_details.merge({
        file: file,
        from: local_path,
        to: bucket_path
      })

      Rails.logger.info(logging_details.to_json)
      bucket.create_file(local_path.to_s, bucket_path)

      Rails.logger.info(logging_details.to_json)
    end
  end

  def load_to_bigquery
    logging_details = { phase: 'bigquery import' }
    Rails.logger.info(logging_details.to_json)

    Dir.children(tmpdir).each do |file|
      endpoint = "gs://#{BUCKET}/json_export/#{runtime}/#{file}"
      table_id = file.sub('.json', '')

      logging_details = logging_details.merge({
        bucket_endpoint: endpoint,
        dataset: BIGQUERY_DATASET,
        file: file,
        maximum_bad_records_allowed: bad_records[file],
        table_id: table_id,
      })

      Rails.logger.info(logging_details)

      if dataset.load(
          table_id,
          endpoint,
          autodetect: true,
          format: 'json',
          max_bad_records: bad_records[file],
          write: 'truncate'
      )
        table = dataset.table(table_id)
        logging_details = logging_details.merge({
          records_loaded:  table.rows_count
        })
      else
        logging_details = logging_details.merge({ status: 'failed' })
      end
      Rails.logger.info(logging_details)
    end
  end
end
