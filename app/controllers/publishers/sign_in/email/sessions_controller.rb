class Publishers::SignIn::Email::SessionsController < ApplicationController
  EMERGENCY_LOGIN_KEY_DURATION = 10.minutes

  before_action :redirect_signed_in_publishers, only: %i[new create check_your_email choose_organisation]
  before_action :redirect_for_dsi_authentication, only: %i[new create check_your_email change_organisation choose_organisation]
  before_action :redirect_unauthorised_publishers, only: %i[create]

  def create
    session.update(publisher_organisation_id: params[:organisation_id])
    trigger_sign_in_event(:success, :email)
    redirect_to organisation_path
  end

  def check_your_email
    publisher = Publisher.find_by(email: params.dig(:publisher, :email).downcase.strip)
    send_login_key(publisher: publisher) if publisher
  end

  def choose_organisation
    information = GetInformationFromLoginKey.new(get_key)
    @reason_for_failing_sign_in = information.reason_for_failing_sign_in
    @schools = information.schools
    @trusts = information.trusts
    @local_authorities = information.local_authorities
    sign_in_publisher(information.details_to_update_in_session)

    return if information.multiple_organisations? || @reason_for_failing_sign_in.present?

    redirect_to auth_email_create_session_path(
      organisation_id: (@schools&.first&.presence || @trusts&.first&.presence || @local_authorities&.first&.presence).id,
    )
  end

  private

  def redirect_signed_in_publishers
    redirect_to organisation_path if current_organisation.present?
  end

  def sign_in_publisher(options)
    return unless options[:oid]

    publisher = Publisher.find_by(oid: options[:oid])
    sign_in(publisher)
    sign_out(:jobseeker)
  end

  def get_key
    params_login_key = params[:login_key]
    begin
      EmergencyLoginKey.find(params_login_key)
    rescue StandardError
      nil
    end
  end

  def send_login_key(publisher:)
    Publishers::AuthenticationFallbackMailer.sign_in_fallback(
      login_key_id: generate_login_key(publisher: publisher).id,
      publisher: publisher,
    ).deliver_later
  end

  def generate_login_key(publisher:)
    publisher.emergency_login_keys.create(not_valid_after: Time.current + EMERGENCY_LOGIN_KEY_DURATION)
  end

  def redirect_for_dsi_authentication
    redirect_to new_publisher_session_path unless AuthenticationFallback.enabled?
  end

  def redirect_unauthorised_publishers
    return if publisher_authorised? && allowed_la_publisher?

    trigger_sign_in_event(:failure, :email)
    redirect_to new_auth_email_path, notice: t(".not_authorised")
  end

  def publisher_authorised?
    @organisation = Organisation.find_by(id: params[:organisation_id])

    current_publisher.dsi_data&.dig("la_codes")&.include?(@organisation.local_authority_code) ||
      current_publisher.dsi_data&.dig("trust_uids")&.include?(@organisation.uid) ||
      current_publisher.dsi_data&.dig("school_urns")&.include?(@organisation.urn)
  end

  def allowed_la_publisher?
    return true unless Rails.configuration.enforce_local_authority_allowlist
    return true unless @organisation.local_authority_code

    Rails.configuration.allowed_local_authorities.include?(@organisation.local_authority_code)
  end

  def trigger_sign_in_event(success_or_failure, sign_in_type, publisher_oid = nil)
    request_event.trigger(
      :publisher_sign_in_attempt,
      user_anonymised_publisher_id: StringAnonymiser.new(publisher_oid),
      success: success_or_failure == :success,
      sign_in_type: sign_in_type,
    )
  end
end
