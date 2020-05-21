require 'dfe_sign_in_api'
require 'google/cloud/bigquery'

class BaseDsiExporter
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

  def insert_rows
    (1..number_of_pages).each do |page|
      response = api_response(page: page)
      raise error_message_for(response) if users_nil_or_empty?(response)

      insert_table_data(response['users'])
    end
  end
end
