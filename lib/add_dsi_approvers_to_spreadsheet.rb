require 'dfe_sign_in_api'
require 'spreadsheet_writer'

class AddDSIApproversToSpreadsheet
  def initialize
    @worksheet = Spreadsheet::Writer.new(DSI_USER_SPREADSHEET_ID, DSI_APPROVER_WORKSHEET_GID, true)
  end

  def all_service_approvers
    number_of_pages = total_page_number

    @worksheet.clear_all_rows
    (1..number_of_pages).each do |page|
      response = DFESignIn::API.new.approvers(page: page)
      raise error_message_for(response) if users_nil_or_empty?(response)

      rows = response_to_rows(response)
      @worksheet.append_rows(rows)

    rescue StandardError => e
      Rails.logger.warn("DSI API failed to respond at page #{page} with error: #{e.message}")
    end
  rescue StandardError => e
    Rails.logger.warn("DSI API failed to respond with error: #{e.message}")
  end

  private

  def total_page_number
    response = DFESignIn::API.new.approvers
    raise error_message_for(response) if response['numberOfPages'].nil?

    response['numberOfPages']
  end

  def response_to_rows(approvers_response)
    approvers_response['users'].map do |user|
      [
        user['roleName'],
        user['userId'],
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

  def users_nil_or_empty?(response)
    response['users'].nil? || response['users'].first.empty?
  end

  def error_message_for(response)
    response['message'] || 'failed request'
  end
end
