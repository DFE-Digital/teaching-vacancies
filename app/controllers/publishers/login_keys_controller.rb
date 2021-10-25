class Publishers::LoginKeysController < ApplicationController
  EMERGENCY_LOGIN_KEY_DURATION = 10.minutes

  before_action :redirect_signed_in_publishers, only: %i[new create show]
  before_action :redirect_for_dsi_authentication, only: %i[new create show]

  def create
    publisher = Publisher.find_by(email: params.dig(:publisher, :email).downcase.strip)
    send_login_key(publisher: publisher) if publisher
  end

  def show
    login_key = EmergencyLoginKey.find_by(id: params[:id])
    return @reason_for_failing_sign_in = "no_key" unless login_key
    return @reason_for_failing_sign_in = "expired" if login_key.expired?

    @publisher = Publisher.find(login_key.publisher_id)
    login_key.destroy
    session.update(publisher_id: @publisher.id)

    return @reason_for_failing_sign_in = "no_orgs" if @publisher.organisations.none?
    return if @publisher.organisations.many?

    redirect_to create_publisher_session_path(organisation_id: @publisher.organisations.first.id)
  end

  private

  def redirect_signed_in_publishers
    return unless publisher_signed_in? && current_organisation.present?

    redirect_to organisation_path
  end

  def redirect_for_dsi_authentication
    return if AuthenticationFallback.enabled?

    redirect_to new_publisher_session_path
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
end
