class Publishers::SignIn::Email::SessionsController < ApplicationController
  EMERGENCY_LOGIN_KEY_DURATION = 10.minutes

  before_action :redirect_signed_in_publishers, only: %i[new create check_your_email choose_organisation]
  before_action :redirect_for_dsi_authentication, only: %i[new create check_your_email choose_organisation]

  def create
    publisher = Publisher.find(session[:publisher_id])
    organisation = publisher.organisations.find(params[:organisation_id])

    if publisher.organisations.include?(organisation) && allowed_la_publisher?(organisation)
      sign_in(publisher)
      sign_out(:jobseeker)
      session.update(publisher_organisation_id: organisation.id)
      trigger_publisher_sign_in_event(:success, :email)
      redirect_to organisation_path
    else
      trigger_publisher_sign_in_event(:failure, :email, publisher.oid)
      redirect_to new_auth_email_path, notice: t(".not_authorised")
    end
  end

  def check_your_email
    publisher = Publisher.find_by(email: params.dig(:publisher, :email).downcase.strip)
    send_login_key(publisher: publisher) if publisher
  end

  def choose_organisation
    process_login_key
    session.update(publisher_id: @publisher.id) if @publisher

    @reason_for_failing_sign_in = "no_orgs" if @publisher&.organisations&.none?
    return if @publisher&.organisations&.many? || @reason_for_failing_sign_in.present?

    redirect_to auth_email_create_session_path(organisation_id: @publisher.organisations.first.id)
  end

  private

  def redirect_signed_in_publishers
    redirect_to organisation_path if current_organisation.present?
  end

  def redirect_for_dsi_authentication
    redirect_to new_publisher_session_path unless AuthenticationFallback.enabled?
  end

  def process_login_key
    login_key = EmergencyLoginKey.find_by(id: params[:login_key])
    return @reason_for_failing_sign_in = "no_key" unless login_key

    if login_key.expired?
      @reason_for_failing_sign_in = "expired"
    else
      @publisher = Publisher.find(login_key.publisher_id)
      login_key.destroy
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

  def allowed_la_publisher?(organisation)
    return true unless Rails.configuration.enforce_local_authority_allowlist
    return true unless organisation.local_authority_code.present?

    Rails.configuration.allowed_local_authorities.include?(organisation.local_authority_code)
  end
end
