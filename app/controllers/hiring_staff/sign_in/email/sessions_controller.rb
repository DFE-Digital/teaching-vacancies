class HiringStaff::SignIn::Email::SessionsController < HiringStaff::SignIn::BaseSessionsController
  EMERGENCY_LOGIN_KEY_DURATION = 10.minutes

  skip_before_action :check_session
  skip_before_action :check_terms_and_conditions

  before_action :redirect_signed_in_users,
    only: %i[new create check_your_email choose_organisation]
  before_action :check_flag,
    only: %i[new create check_your_email change_organisation choose_organisation]

  def new; end

  def create
    redirect_to new_auth_email_path unless user_authorised?
    session.update(urn: get_urn)
    Rails.logger.info("Updated session with URN #{session[:urn]}")
    redirect_to school_path
  end

  def destroy
    end_session_and_redirect
  end

  def check_your_email
    user = User.find_by(email: params.dig(:user, :email).downcase.strip)
    send_login_key(user: user) if user
  end

  def change_organisation
    key = generate_login_key(user: current_user)
    session.destroy
    redirect_to auth_email_choose_organisation_path(login_key: key.id)
  end

  def choose_organisation
    key = get_key
    if key&.expired?
      @reason_for_denial = 'expired'
    elsif key
      user = key.user_id ? User.find(key.user_id) : nil
      key&.destroy
      @schools = get_schools(user)
      # TODO: include school_groups here when we have implemented school groups/trusts/LAs
      @reason_for_denial = 'no_orgs' if @schools.empty?
      @has_multiple_schools = @schools.size > 1
      update_session_without_urn(@has_multiple_schools, user&.oid)
    else
      @reason_for_denial = 'no_key'
    end
  end

  private

  def user_authorised?
    user = User.find_by(oid: session[:session_id]) rescue nil
    user&.dsi_data&.dig('school_urns')&.include? get_urn
    # TODO: include school_groups here when we have implemented school groups/trusts/LAs
  end

  def update_session_without_urn(multiple_schools, oid)
    return unless oid
    session.update(
      session_id: oid,
      multiple_schools: multiple_schools
    )
    # Session is expired after the time set in config/initializers/session_store.rb
    Rails.logger.warn("Hiring staff signed in: #{oid}")
  end

  def get_schools(user)
    schools = []
    user&.dsi_data&.dig('school_urns')&.each do |urn|
      school_query = School.where(urn: urn)
      schools.push SchoolPresenter.new(school_query.first) unless school_query.empty?
    end
    schools
  end

  def get_urn
    params.dig(:urn)
  end

  def get_key
    params_login_key = params.dig(:login_key)
    EmergencyLoginKey.find(params_login_key) rescue nil
  end

  def send_login_key(user:)
    AuthenticationFallbackMailer.sign_in_fallback(
      login_key: generate_login_key(user: user),
      email: user.email
    ).deliver_later
  end

  def generate_login_key(user:)
    user.emergency_login_keys.create(not_valid_after: Time.zone.now + EMERGENCY_LOGIN_KEY_DURATION)
  end

  def check_flag
    redirect_to new_identifications_path unless AuthenticationFallback.enabled?
  end
end
