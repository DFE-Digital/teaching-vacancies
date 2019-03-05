class HiringStaff::BaseController < ApplicationController
  before_action :check_session
  before_action :check_terms_and_conditions

  helper_method :current_school

  include AuthenticationConcerns

  def check_session
    redirect_to new_identifications_path unless session.key?(:urn)
  end

  def check_terms_and_conditions
    redirect_to terms_and_conditions_path unless current_user&.accepted_terms_and_conditions?
  end

  def current_session_id
    session[:session_id]
  end

  def current_school
    @current_school ||= School.find_by!(urn: session[:urn])
  end

  def current_user
    return if current_session_id.blank?

    @current_user ||= User.find_or_create_by(oid: current_session_id)
  end
end
