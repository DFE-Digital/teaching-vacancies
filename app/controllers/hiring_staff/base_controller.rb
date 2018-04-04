class HiringStaff::BaseController < ApplicationController
  before_action :check_session

  def check_session
    redirect_to new_sessions_path unless session.key?(:urn)
  end

  def current_school
    @current_school ||= School.find_by! urn: session[:urn]
  end
end
