class HiringStaff::BaseController < ApplicationController
  TIMEOUT_PERIOD = 60.minutes

  before_action :check_user_last_activity_at,
                :update_user_last_activity_at,
                :redirect_to_root_if_read_only,
                :check_session,
                :check_terms_and_conditions

  include AuthenticationConcerns
  include ActionView::Helpers::DateHelper

  def redirect_to_root_if_read_only
    redirect_to root_path if ReadOnlyFeature.enabled?
  end

  def check_session
    redirect_to new_identifications_path unless
      session[:urn].present? || session[:uid].present? || session[:la_code].present?
  end

  def check_terms_and_conditions
    redirect_to terms_and_conditions_path unless current_publisher&.accepted_terms_and_conditions?
  end

  def current_publisher
    return if current_session_id.blank?

    @current_publisher ||= Publisher.find_or_create_by(oid: current_session_id)
  end

  def current_publisher_preferences
    return unless current_organisation.is_a?(SchoolGroup)

    PublisherPreference.find_by(publisher_id: current_publisher.id, school_group_id: current_organisation.id)
  end

  def check_user_last_activity_at
    return redirect_to logout_endpoint if current_publisher&.last_activity_at.blank?

    if Time.current > (current_publisher.last_activity_at + TIMEOUT_PERIOD)
      session[:signing_out_for_inactivity] = true
      redirect_to logout_endpoint
    end
  end

  def update_user_last_activity_at
    current_publisher&.update(last_activity_at: Time.current)
  end

  def logout_endpoint
    return auth_email_sign_out_path if AuthenticationFallback.enabled?

    url = URI.parse("#{ENV['DFE_SIGN_IN_ISSUER']}/session/end")
    url.query = { post_logout_redirect_uri: auth_dfe_signout_url, id_token_hint: session[:id_token] }.to_query
    url.to_s
  end

  def redirect_signed_in_publishers
    redirect_to organisation_path if current_organisation.present?
  end

  def timeout_period_as_string
    distance_of_time_in_words(TIMEOUT_PERIOD).gsub("about ", "")
  end

  def verify_school_group
    redirect_to organisation_path, danger: "You are not allowed" unless current_organisation.is_a?(SchoolGroup)
  end
end
