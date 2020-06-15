class HiringStaff::BaseController < ApplicationController
  TIMEOUT_PERIOD = 60.minutes

  before_action :check_user_last_activity_at,
    :update_user_last_activity_at,
    :redirect_to_root_if_read_only,
    :check_session,
    :check_terms_and_conditions

  helper_method :current_school

  include AuthenticationConcerns
  include ActionView::Helpers::DateHelper

  def redirect_to_root_if_read_only
    redirect_to root_path if ReadOnlyFeature.enabled?
  end

  def check_session
    redirect_to sign_in_path unless session.key?(:urn)
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
    return redirect_to logout_endpoint if current_user&.last_activity_at.blank?

    if Time.zone.now > (current_user.last_activity_at + TIMEOUT_PERIOD)
      session[:signing_out_for_inactivity] = true
      redirect_to logout_endpoint
    end
  end

  def update_user_last_activity_at
    current_user&.update(last_activity_at: Time.zone.now)
  end

  def logout_endpoint
    return auth_email_sign_out_path if AuthenticationFallback.enabled?
    url = URI.parse("#{ENV['DFE_SIGN_IN_ISSUER']}/session/end")
    url.query = { post_logout_redirect_uri: auth_dfe_signout_url, id_token_hint: session[:id_token] }.to_query
    url.to_s
  end

  def sign_in_path
    AuthenticationFallback.enabled? ? new_identifications_path : new_auth_email_path
  end

  def redirect_signed_in_users
    return redirect_to school_path if session.key?(:urn)
  end

  def timeout_period_as_string
    distance_of_time_in_words(TIMEOUT_PERIOD).gsub('about ', '')
  end
end
