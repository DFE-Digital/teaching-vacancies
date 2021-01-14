class PagesController < ApplicationController
  include HighVoltage::StaticPage

  def invalid_page
    not_found
  end

  private

  def set_headers
    response.set_header("X-Robots-Tag", "index, nofollow")
  end
end
