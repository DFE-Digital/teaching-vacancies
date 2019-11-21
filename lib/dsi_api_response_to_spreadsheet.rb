require 'dfe_sign_in_api'
require 'spreadsheet_writer'
require 'date_helper'

class DsiAPIResponseToSpreadsheet
  include DateHelper

  def write_all_response_to_spreadsheet(endpoint)
    number_of_pages = total_page_number(endpoint)

    @worksheet.clear_all_rows
    (1..number_of_pages).each do |page|
      response = DFESignIn::API.new.send(endpoint, page: page)
      raise error_message_for(response) if users_nil_or_empty?(response)

      rows = response_to_rows(response)
      @worksheet.append_rows(rows)

    rescue StandardError => e
      Rails.logger.warn("DSI API #{endpoint} failed to respond at page #{page} with error: #{e.message}")
      raise
    end
  rescue StandardError => e
    Rails.logger.warn("DSI API #{endpoint} failed to respond with error: #{e.message}")
    raise
  end

  private

  def total_page_number(endpoint)
    response = DFESignIn::API.new.send(endpoint)
    raise error_message_for(response) if response['numberOfPages'].nil?

    response['numberOfPages']
  end

  def users_nil_or_empty?(response)
    response['users'].nil? || response['users'].first.empty?
  end

  def error_message_for(response)
    response['message'] || 'failed request'
  end
end
