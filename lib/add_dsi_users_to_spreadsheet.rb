require 'dfe_sign_in_api'
require 'spreadsheet_writer'
require 'date_helper'

class AddDSIUsersToSpreadsheet
  include DateHelper

  def initialize
    @worksheet = Spreadsheet::Writer.new(DSI_USER_SPREADSHEET_ID, DSI_USER_WORKSHEET_GID, true)
  end

  def all_service_users
    number_of_pages = total_page_number

    @worksheet.clear_all_rows
    (1..number_of_pages).each do |page|
      response = DFESignIn::API.new.users(page: page)
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
    response = DFESignIn::API.new.users
    raise error_message_for(response) if response['numberOfPages'].nil?

    response['numberOfPages']
  end

  # rubocop:disable Metrics/AbcSize
  def response_to_rows(users_response)
    users_response['users'].map do |user|
      [
        user['roleName'],
        user['userId'],
        format_datetime_with_seconds(user['approvedAt']),
        format_datetime_with_seconds(user['updatedAt']),
        user['givenName'],
        user['familyName'],
        user['email'],
        user['organisation']['URN'],
        user['organisation']['name'],
        user['organisation']['Status'],
        user['organisation']['phaseOfEducation'],
        user['organisation']['telephone'],
        user['organisation']['regionCode'],
        format_datetime_with_seconds(user['organisation']['createdAt']),
        format_datetime_with_seconds(user['organisation']['updatedAt'])
      ]
    end
  end
  # rubocop:enable Metrics/AbcSize

  def users_nil_or_empty?(response)
    response['users'].nil? || response['users'].first.empty?
  end

  def error_message_for(response)
    response['message'] || 'failed request'
  end
end
