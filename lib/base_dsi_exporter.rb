require 'dfe_sign_in_api'
require 'google/cloud/bigquery'

class BaseDsiExporter
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

  def number_of_pages
    response = api_response
    raise (response['message'] || 'failed request') if response['numberOfPages'].nil?

    response['numberOfPages']
  end

  def users_nil_or_empty?(response)
    response['users'].nil? || response['users'].first.empty?
  end

  def error_message_for(response)
    response['message'] || 'failed request'
  end
end
