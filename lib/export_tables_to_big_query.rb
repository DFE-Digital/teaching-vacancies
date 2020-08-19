require 'google/cloud/bigquery'

class ExportTablesToBigQuery
  include Google::Cloud

  BIGQUERY_DATASET = ENV['BIG_QUERY_DATASET']
  # This is to allow us to load new tables to the production dataset without disturbing the existing ones.
  BIGQUERY_TABLE_PREFIX = 'feb20'.freeze

  # Attributes with postgres schema types that do not exist in BigQuery.
  CONVERT_THESE_TYPES = { point: :float, text: :string, uuid: :string, json: :string }.freeze

  # Skip attributes that cannot be queried, we do not report on or that frequently break the import.
  # Drop gias_data because it is aliased to data. This alias allows all records to be handled the same way and dropping
  # gias_data removes duplication of data.
  DROP_THESE_ATTRIBUTES = %w[
    benefits
    data
    description
    education
    experience
    frequency
    geolocation
    gias_data
    job_summary
    legacy_job_roles
    qualifications
    supporting_documents
  ].freeze

  # This is to deal with a gem that automatically maps an interger column to a look up table of strings.
  ENUM_ATTRIBUTES = {
    'frequency' => :string,
    'hired_status' => :string,
    'job_roles' => :string,
    'listed_elsewhere' => :string,
    'phase' => :string,
    'search_criteria' => :string,
    'status' => :string,
    'user_participation_response' => :string,
    'visit_purpose' => :string,
    'working_patterns' => :string,
  }.freeze

  EXCLUDE_TABLES = %w[
    activities
    ar_internal_metadata
    audit_data
    friendly_id_slugs
    location_polygons
    schema_migrations
    sessions
  ].freeze

  attr_reader :dataset, :runtime, :tables

  def initialize(bigquery: Bigquery.new)
    @dataset = bigquery.dataset(BIGQUERY_DATASET)
    @runtime = DateTime.now.to_s(:db).parameterize
    # This ensures that new tables are automatically added to the BigQuery dataset.
    #
    # `#singularize` must come *after* `#camelize` in `#map` for the AuditData inflection rule to work correctly. The
    # inflector wasn't correctly picking up the snake cased version.
    @tables = ApplicationRecord.connection.tables
      .reject { |table| EXCLUDE_TABLES.include?(table) }
      .sort
      .map { |table| table.camelize.singularize }
      .freeze
  end

  def run!
    Rails.logger.info({ bigquery_export: 'started' }.to_json)
    tables.each do |table|
      bigquery_load(table.constantize)
    rescue StandardError => e
      # If any table causes an uncaught error, no data from any later table is sent.
      # Catch errors and skip the failing tables
      # TODO: alert the team (devs + PA) to any failing tables.
      Rails.logger.error({ bigquery_export: 'error', status: 'handled', table: table, message: e })
    end
    Rails.logger.info({ bigquery_export: 'finished' }.to_json)
  end

  private

  def bigquery_data(record, table)
    @bigquery_data = {}

    table.columns.map do |c|
      next if DROP_THESE_ATTRIBUTES.include?(c.name) && table.name != 'SchoolGroup'
      data = record.send(c.name)
      # Another bloody enum gem edge case. Only in vacancies and causes that whole table to fail despite the column
      # being nullable.
      data = '' if c.name == 'hired_status' && data.nil?
      # This prevents an error whereby BigQuery rejects arrays of exactly one element.
      data = data.to_s if c.name == 'job_roles'
      data = data.to_s if c.name == 'subjects'
      data = data.to_s if c.name == 'working_patterns'
      data = data.to_s(:db) if !data.nil? && (c.type == :datetime || c.type == :date)
      data = data.to_s if c.type == :json
      @bigquery_data[c.name] = data
    end

    if table.column_names.include?('geolocation')
      @bigquery_data['geolocation_x'] = record.geolocation.x
      @bigquery_data['geolocation_y'] = record.geolocation.y
    end

    json_record = record.data if record.respond_to?(:data)
    return @bigquery_data if json_record.nil?

    json_record.map do |key, value|
      data = value.presence
      data = Date.parse(data).to_s(:db) if data.is_a?(String) && data.match?(/^\d{2}\-\d{2}\-\d{4}/)
      data = data.to_i if data.is_a?(String) && data.match?(/^\d+$/)
      @bigquery_data[data_key_name(key)] = data
    end

    @bigquery_data
  end

  def bigquery_load(db_table)
    started_at = DateTime.now.to_s(:db)
    table_name = [BIGQUERY_TABLE_PREFIX, db_table.to_s.downcase].join('_')
    dataset.table(table_name)&.delete
    bq_table = dataset.table(table_name) || dataset.create_table(table_name) do |schema|
      bigquery_schema(db_table).each do |column_name, column_type|
        schema.send(column_type, column_name)
      end
    end

    record_count = total = db_table.count
    error_count = 0

    inserter = bq_table.insert_async ignore_unknown: true, skip_invalid: true do |result|
      if result.error?
        Rails.logger.error({
          table: table_name,
          error: result.error
        }.to_json)
      else
        Rails.logger.info({
          table: table_name,
          inserted: result.insert_count,
          remaining: total,
          error_count: result.error_count
        }.to_json)

        if result.error_count > 0
          Rollbar.warning(result.insert_errors)
          Rails.logger.error(result.insert_errors)
          error_count += result.error_count
          record_count -= result.error_count
        end

        total -= result.insert_count
      end
    end

    db_table.find_in_batches(batch_size: inserter.max_rows) do |batch|
      inserter.insert batch.map { |record| bigquery_data(record, db_table) }
    end

    monitoring({
      error_count: error_count,
      finished_at: DateTime.now.to_s(:db),
      records_processed: record_count,
      started_at: started_at,
      table: table_name
    })

    inserter.stop.wait!
  end

  def bigquery_schema(table)
    @bigquery_schema = {}

    table.columns.map do |c|
      next if DROP_THESE_ATTRIBUTES.include?(c.name) && table.name != 'SchoolGroup'
      @bigquery_schema[c.name] = ENUM_ATTRIBUTES[c.name] || CONVERT_THESE_TYPES[c.type] || c.type
    end.compact

    if table.column_names.include?('geolocation')
      @bigquery_schema['geolocation_x'] = :float
      @bigquery_schema['geolocation_y'] = :float
    end

    json_template = table.where.not(data: nil).first.data.presence if table.first.respond_to?(:data)
    return @bigquery_schema if json_template.nil?

    json_template.sort_by { |k, _| k }.map do |key, value|
      data_type = :string
      data_type = :date if key.match?(/date/i)
      data_type = :integer if value.match(/^\d+$/) && !key.match(/diocese/i)
      @bigquery_schema[data_key_name(key)] = data_type
    end

    @bigquery_schema
  end

  def data_key_name(key)
    "data_#{key.chomp(')').gsub(/\W+/, '_').downcase}"
  end

  def monitoring(data)
    Rails.logger.info(data.to_json)
    table = dataset.table('monitoring') || dataset.create_table('monitoring') do |schema|
      schema.integer 'error_count'
      schema.timestamp 'finished_at'
      schema.integer 'records_processed'
      schema.timestamp 'started_at'
      schema.string 'table'
    end

    table.insert(data)
  end
end
