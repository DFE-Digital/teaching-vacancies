require 'dfe_sign_in_api'

class AddDSIUsersToSpreadsheet
  def all_service_users
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
