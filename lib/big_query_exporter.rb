require 'google/cloud/bigquery'

class BigQueryExporter
  attr_reader :dataset

  def initialize(bigquery: Google::Cloud::Bigquery.new)
    @dataset = bigquery.dataset ENV.fetch('BIG_QUERY_DATASET')
  end

  private

  def delete_table(table_name)
    table = dataset.table table_name
    return if table.nil?
    dataset.reload! if table.delete
  end

  def format_as_date(date)
    date&.strftime('%F')
  end

  def format_as_timestamp(datetime)
    datetime&.strftime('%FT%T%:z')
  end
end
