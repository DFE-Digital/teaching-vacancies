require 'dfe_sign_in_api'
require 'spreadsheet_writer'
require 'date_helper'

class AddDSIApproversToSpreadsheet
  include DateHelper
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

  # rubocop:disable Metrics/AbcSize
  def response_to_rows(approvers_response)
    approvers_response['users'].map do |user|
      [
        user['roleName'],
        user['userId'],
        user['givenName'],
        user['familyName'],
        user['email'],
        user.dig('organisation', 'id'),
        user.dig('organisation', 'name'),
        user.dig('organisation', 'category', 'name'),
        user.dig('organisation', 'type', 'name'),
        user.dig('organisation', 'urn'),
        user.dig('organisation', 'status', 'name'),
        format_datetime_with_seconds(user.dig('organisation', 'closedOn')),
        user.dig('organisation', 'address'),
        user.dig('organisation', 'telephone'),
        user.dig('organisation', 'region', 'name'),
        user.dig('organisation', 'phaseOfEducation', 'name'),
        user.dig('organisation', 'statutoryLowAge'),
        user.dig('organisation', 'statutoryHighAge'),
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
