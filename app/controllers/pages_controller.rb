class PagesController < ApplicationController
  include HighVoltage::StaticPage

  def invalid_page
    redirect_to '/404'
  end
end