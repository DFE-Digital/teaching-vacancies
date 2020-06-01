require 'dfe_sign_in_api'
require 'google/cloud/bigquery'

class BaseDsiBigQueryExporter
  include DFESignIn

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
end
