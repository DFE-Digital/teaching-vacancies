class PagesController < ApplicationController
  include HighVoltage::StaticPage

  layout :landing_page_layout

  def invalid_page
    not_found
  end

  private

  def landing_page_layout
    "landing_page" if params[:id] == "list-school-job"
  end

  def set_headers
    response.set_header("X-Robots-Tag", "index, nofollow")
  end
end
