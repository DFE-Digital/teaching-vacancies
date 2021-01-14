class Publishers::SignIn::Email::SessionsController < Publishers::SignIn::BaseSessionsController
  EMERGENCY_LOGIN_KEY_DURATION = 10.minutes

  skip_before_action :check_session
  skip_before_action :check_terms_and_conditions

  before_action :redirect_signed_in_publishers,
                only: %i[new create check_your_email choose_organisation]
  before_action :redirect_for_dsi_authentication,
                only: %i[new create check_your_email change_organisation choose_organisation]
  before_action :redirect_unauthorised_publishers, only: %i[create]

  def new; end

  def create
    session.update(organisation_urn: params[:urn], organisation_uid: params[:uid], organisation_la_code: params[:la_code])
    Rails.logger.info(updated_session_details)
    redirect_to organisation_path
  end

  def destroy
    Rails.logger.info("Hiring staff clicked sign out via fallback authentication: #{session[:publisher_oid]}")
    end_session_and_redirect
  end

  def check_your_email
    publisher = Publisher.find_by(email: params.dig(:publisher, :email).downcase.strip)
    send_login_key(publisher: publisher) if publisher
  end

  def change_organisation
    key = generate_login_key(publisher: current_publisher)
    clear_publisher_session!
    redirect_to auth_email_choose_organisation_path(login_key: key.id)
  end

  def choose_organisation
    information = GetInformationFromLoginKey.new(get_key)
    @reason_for_failing_sign_in = information.reason_for_failing_sign_in
    @schools = information.schools
    @trusts = information.trusts
    @local_authorities = information.local_authorities
    update_session_except_org_id(information.details_to_update_in_session)

    return if information.multiple_organisations? || @reason_for_failing_sign_in.present?

    redirect_to auth_email_create_session_path(
      urn: @schools&.first&.urn,
      uid: @trusts&.first&.uid,
      la_code: @local_authorities&.first&.local_authority_code,
    )
  end

  private

  def update_session_except_org_id(options)
    return unless options[:oid]

    session.update(
      publisher_oid: options[:oid],
      publisher_multiple_organisations: options[:multiple_organisations],
    )
    Rails.logger.warn("Hiring staff signed in via fallback authentication: #{options[:oid]}")
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
    AuthenticationFallbackMailer.sign_in_fallback(
      login_key: generate_login_key(publisher: publisher),
      email: publisher.email,
    ).deliver_later
  end

  def generate_login_key(publisher:)
    publisher.emergency_login_keys.create(not_valid_after: Time.current + EMERGENCY_LOGIN_KEY_DURATION)
  end

  def redirect_for_dsi_authentication
    redirect_to new_identifications_path unless AuthenticationFallback.enabled?
  end

  def redirect_unauthorised_publishers
    redirect_to new_auth_email_path, notice: t(".not_authorised") unless publisher_authorised?
  end

  def publisher_authorised?
    publisher = begin
      Publisher.find_by(oid: session.to_h["publisher_oid"])
    rescue StandardError
      nil
    end

    allowed_publisher? &&
      (publisher&.dsi_data&.dig("la_codes")&.include?(params[:la_code]) ||
       publisher&.dsi_data&.dig("trust_uids")&.include?(params[:uid]) ||
       publisher&.dsi_data&.dig("school_urns")&.include?(params[:urn]))
  end

  def allowed_publisher?
    params[:urn].present? || params[:uid].present? || (params[:la_code].present? &&
      (Rails.env.staging? || Rails.env.development? || ALLOWED_LOCAL_AUTHORITIES.include?(params[:la_code])))
  end
end
