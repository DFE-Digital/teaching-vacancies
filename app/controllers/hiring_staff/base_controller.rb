class HiringStaff::BaseController < ApplicationController
  TIMEOUT_PERIOD = 60.minutes

  before_action :check_user_last_activity_at,
    :update_user_last_activity_at,
    :redirect_to_root_if_read_only,
    :check_session,
    :check_terms_and_conditions

  helper_method :current_school

  include AuthenticationConcerns

  def redirect_to_root_if_read_only
    redirect_to root_path if ReadOnlyFeature.enabled?
  end

  def check_session
    redirect_to new_identifications_path unless session.key?(:urn)
  end

  def check_terms_and_conditions
    redirect_to terms_and_conditions_path unless current_user&.accepted_terms_and_conditions?
  end

  def current_school
    @current_school ||= School.find_by!(urn: session[:urn])
  end

  def current_user
    return if current_session_id.blank?

    @current_user ||= User.find_or_create_by(oid: current_session_id)
  end

  def check_user_last_activity_at
    # config/session_store.rb expires sessions after 8 hours of inactivity,
    # resulting in current_user == nil.

    # TODO: remove config/session_store.rb when it has become redundant.

    # The session_store.rb behaviour does not meet security requirements
    # as it does not call the dsi_logout_url. Rather it only deletes our session,
    # so the user may still be logged in on DSI, so signing in
    # will skip the requirement to enter a password.
    if current_user&.last_activity_at.blank?
      redirect_to dsi_logout_url
    elsif Time.zone.now > (current_user.last_activity_at + TIMEOUT_PERIOD)
      session[:signing_out_for_inactivity] = true
      redirect_to dsi_logout_url
    end
  end

  def update_user_last_activity_at
    return if current_user.blank?
    current_user.update(last_activity_at: Time.zone.now)
  end

  def dsi_logout_url
    url = URI.parse("#{ENV['DFE_SIGN_IN_ISSUER']}/session/end")
    url.query = { post_logout_redirect_uri: auth_dfe_signout_url, id_token_hint: session[:id_token] }.to_query
    url.to_s
  end
end
