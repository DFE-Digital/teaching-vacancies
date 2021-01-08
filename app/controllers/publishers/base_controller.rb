class Publishers::BaseController < ApplicationController
  TIMEOUT_PERIOD = 60.minutes

  before_action :authenticate_publisher!,
                :update_publisher_last_activity_at,
                :redirect_to_root_if_read_only,
                :check_session,
                :check_terms_and_conditions

  include ActionView::Helpers::DateHelper

  def redirect_to_root_if_read_only
    redirect_to root_path if ReadOnlyFeature.enabled?
  end

  def check_session
    redirect_to new_identifications_path unless
      session[:organisation_urn].present? || session[:organisation_uid].present? || session[:organisation_la_code].present?
  end

  def check_terms_and_conditions
    redirect_to terms_and_conditions_path unless current_publisher&.accepted_terms_and_conditions?
  end

  def current_publisher
    return if current_publisher_oid.blank?

    @current_publisher ||= Publisher.find_or_create_by(oid: current_publisher_oid)
  end

  def current_publisher_preferences
    return unless current_organisation.is_a?(SchoolGroup)

    PublisherPreference.find_by(publisher_id: current_publisher.id, school_group_id: current_organisation.id)
  end

  def authenticate_publisher!
    return redirect_to(new_identifications_path) unless current_publisher
    return redirect_to(logout_endpoint) if current_publisher.last_activity_at.blank?

    return unless Time.current > (current_publisher.last_activity_at + TIMEOUT_PERIOD)

    session[:publisher_signing_out_for_inactivity] = true
    redirect_to logout_endpoint
  end

  def update_publisher_last_activity_at
    current_publisher&.update(last_activity_at: Time.current)
  end

  def logout_endpoint
    return auth_email_sign_out_path if AuthenticationFallback.enabled?

    url = URI.parse("#{ENV['DFE_SIGN_IN_ISSUER']}/session/end")
    url.query = { post_logout_redirect_uri: auth_dfe_signout_url, id_token_hint: session[:publisher_id_token] }.to_query
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
