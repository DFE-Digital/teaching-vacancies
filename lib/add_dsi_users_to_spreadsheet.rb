require 'dfe_sign_in_api'
require 'spreadsheet_writer'

class AddDSIUsersToSpreadsheet
  def initialize
    @worksheet = Spreadsheet::Writer.new(DSI_USER_SPREADSHEET_ID, DSI_USER_WORKSHEET_GID, true)
  end

  def all_service_users
    @worksheet.clear_all_rows
    total_page_num = total_page_number
    (1..total_page_num).each do |page|
      response = DFESignIn::API.new.users(page: page)
      unless response.with_indifferent_access[:users].first.empty?
        rows = response_to_rows(response)
        @worksheet.append_rows(rows)
      end
    rescue StandardError => e
      Rails.logger.warn("DSI API failed to respond at page #{page} with error: #{e.message}")
    end
  end

  def total_page_number
    DFESignIn::API.new.users.with_indifferent_access[:numberOfPages]
  end

  def response_to_rows(users_response)
    users_response['users'].map do |user|
      [
        user['roleName'],
        user['userId'],
        user['approvedAt'],
        user['updatedAt'],
        user['givenName'],
        user['familyName'],
        user['email'],
        user['organisation']['URN'],
        user['organisation']['name'],
        user['organisation']['Status'],
        user['organisation']['phaseOfEducation'],
        user['organisation']['telephone'],
        user['organisation']['regionCode'],
        user['organisation']['createdAt'],
        user['organisation']['updatedAt']
      ]
    end
  end
end
