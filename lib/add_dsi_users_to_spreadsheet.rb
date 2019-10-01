require 'dfe_sign_in_api'

class AddDSIUsersToSpreadsheet
  def all_service_users
    total_page_num = total_page_number
    (1..total_page_num).each do |page|
      begin
        DFESignIn::API.new.users(page: page)
      rescue => e
        puts "this failed at page #{page}"
        puts "#{e.message}"
        # next
        # Rails.logger.info("Page #{page} of DSI users response could not be received")
      end
    end
  end

  def total_page_number
    DFESignIn::API.new.users[:numberOfPages]
  end
end
