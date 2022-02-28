require "dfe_sign_in_api"
require "google/cloud/bigquery"

class BaseDSIBigQueryExporter
  include DFESignIn

  attr_reader :dataset

  def initialize(bigquery: Google::Cloud::Bigquery.new)
    @dataset = bigquery.dataset(Rails.configuration.big_query_dataset)
  end

  private

  def delete_table(table_name)
    table = dataset.table table_name
    return if table.nil?

    dataset.reload! if table.delete
  end
end
