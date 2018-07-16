class HiringStaff::BaseController < ApplicationController
  before_action :check_session

  include AuthenticationConcerns

  def check_session
    redirect_to new_sessions_path unless session.key?(:urn)
  end

  def current_session_id
    session[:session_id]
  end
end
