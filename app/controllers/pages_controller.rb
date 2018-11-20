class PagesController < ApplicationController
  include HighVoltage::StaticPage

  def invalid_page
    redirect_to '/404'
  end

  def set_headers
    return super if page_path.include?('user-not-authorised')
    response.set_header('X-Robots-Tag', 'index, nofollow')
  end
end
