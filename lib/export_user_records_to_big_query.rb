require 'dfe_sign_in_api'
require 'big_query_exporter'

class ExportUserRecordsToBigQuery < BigQueryExporter
  def run!
    delete_table('users')

    (1..number_of_pages).each do |page|
      response = api_response(page: page)
      raise error_message_for(response) if users_nil_or_empty?(response)

      insert_table_data(response['users'])
    end

  rescue StandardError => e
    Rails.logger.warn("DSI API /users failed to respond with error: #{e.message}")
    raise "#{e.message}, while writing data from DSI /users endpoint. Flag this to Steven + Comms team"
  end

  private

  def present_for_big_query(batch)
    batch.map do |v|
      {
        user_id: v['userId'],
        role: v['roleName'],
        approval_datetime: v['approvedAt'],
        update_datetime: v['updatedAt'],
        given_name: v['givenName'],
        family_name: v['familyName'],
        email: v['email'],
        school_urn: v['organisation']['URN']
      }
    end
  end

  def insert_table_data(batch)
    dataset.insert 'users', present_for_big_query(batch), autocreate: true do |schema|
      schema.string 'user_id', mode: :required
      schema.string 'role', mode: :required
      schema.timestamp 'approval_datetime', mode: :nullable
      schema.timestamp 'update_datetime', mode: :nullable
      schema.string 'given_name', mode: :required
      schema.string 'family_name', mode: :required
      schema.string 'email', mode: :required
      schema.integer 'school_urn', mode: :required
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

  def api_response(page: 1)
    DFESignIn::API.new.users(page: page)
  end
end
