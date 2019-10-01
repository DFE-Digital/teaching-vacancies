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
      DFESignIn::API.new.users(page: page)
    rescue StandardError => e
      Rails.logger.warn("DSI API failed to respond at page #{page} with error: #{e.message}")
    end
  end

  def total_page_number
    DFESignIn::API.new.users[:numberOfPages]
  end
end
