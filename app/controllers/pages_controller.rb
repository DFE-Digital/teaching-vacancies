class PagesController < ApplicationController
  include HighVoltage::StaticPage

  INTERMEDIARY_LANDING_PAGE_IDS = %w[leadership-roles].freeze

  layout :layout_for_page

  def invalid_page
    not_found
  end

  private

  def layout_for_page
    if params[:id].in?(INTERMEDIARY_LANDING_PAGE_IDS)
      "application_intermediary"
    else
      "application"
    end
  end

  def set_headers
    response.set_header("X-Robots-Tag", "index, nofollow")
  end
end
