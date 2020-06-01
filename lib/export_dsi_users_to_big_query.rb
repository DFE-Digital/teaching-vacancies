require 'base_dsi_exporter'

class ExportDsiUsersToBigQuery < BaseDsiBigQueryExporter
  TABLE_NAME = 'dsi_users'

  def run!
    delete_table(TABLE_NAME)
    get_response_pages.each { |page| insert_table_data(page) }
  rescue StandardError => e
    Rails.logger.warn("DSI API /users failed to respond with error: #{e.message}")
    raise "#{e.message}, while writing data from DSI /users endpoint. Flag this to Steven + Comms team"
  end

  private

  def present_for_big_query(batch)
    batch.map do |user|
      {
        user_id: user['userId'],
        role: user['roleName'],
        approval_datetime: user['approvedAt'],
        update_datetime: user['updatedAt'],
        given_name: user['givenName'],
        family_name: user['familyName'],
        email: user['email'],
        school_urn: user.dig('organisation', 'URN')
      }
    end
  end

  def insert_table_data(batch)
    dataset.insert TABLE_NAME, present_for_big_query(batch), autocreate: true do |schema|
      schema.string 'user_id', mode: :nullable
      schema.string 'role', mode: :nullable
      schema.timestamp 'approval_datetime', mode: :nullable
      schema.timestamp 'update_datetime', mode: :nullable
      schema.string 'given_name', mode: :nullable
      schema.string 'family_name', mode: :nullable
      schema.string 'email', mode: :nullable
      schema.integer 'school_urn', mode: :nullable
    end
  end

  def api_response(page: 1)
    DFESignIn::API.new.users(page: page)
  end
end
