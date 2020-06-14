class HiringStaff::IdentificationsController < HiringStaff::BaseController
  EMERGENCY_LOGIN_KEY_DURATION = 10.minutes

  skip_before_action :check_user_last_activity_at
  skip_before_action :check_session,
    only: %i[new create check_your_email choose_organisation sign_in_by_email]
  skip_before_action :check_terms_and_conditions,
    only: %i[new create check_your_email choose_organisation sign_in_by_email]
  skip_before_action :verify_authenticity_token, only: %i[create]

  before_action :redirect_signed_in_users
  before_action :check_flag, only: %i[check_your_email choose_organisation sign_in_by_email]

  def new
    render :authentication_fallback if AuthenticationFallback.enabled?
  end

  def create
    redirect_to new_dfe_path
  end

  # TODO: maybe separate things out into a separate controller.
  # TODO: expire sessions
  def check_your_email
    user = User.find_by(email: params.dig(:user, :email).downcase.strip)
    send_login_key(user: user) if user
  end

  def choose_organisation
    key = get_key
    if key
      user = key&.user_id ? User.find(key.user_id) : nil
    end
    @schools = get_schools(user)
    # TODO: include school_groups here when we have implemented school groups/trusts/LAs
    key&.destroy
    @has_multiple_schools = @schools.size > 1 
    update_session_without_urn(@has_multiple_schools, user&.oid)
  end

  def sign_in_by_email
    redirect_to new_identifications_path unless user_authorised?
    session.update(urn: get_urn)
    Rails.logger.info("Updated session with URN #{session[:urn]}")
    redirect_to school_path
  end

  private

  def user_authorised?
    user = User.find_by(oid: session[:session_id]) rescue nil
    user&.dsi_data&.dig('school_urns')&.include? get_urn
    # TODO: include school_groups here when we have implemented school groups/trusts/LAs
  end

  def redirect_signed_in_users
    return redirect_to school_path if session.key?(:urn)
  end

  def check_flag
    redirect_to new_identifications_path unless AuthenticationFallback.enabled?
  end

  def update_session_without_urn(multiple_schools, oid)
    return unless oid
    session.update(
      session_id: oid,
      multiple_schools: multiple_schools
    )
    Rails.logger.warn("Hiring staff signed in: #{oid}")
  end

  def get_schools(user)
    schools = []
    user&.dsi_data&.dig('school_urns')&.each do |urn|
      schools.push SchoolPresenter.new(School.where(urn: urn).first)
    end
    schools.compact
  end

  def get_urn
    params.dig(:urn)
  end

  def get_key
    params_login_key = params.dig(:login_key)
    EmergencyLoginKey.find(params_login_key) rescue nil
  end

  def send_login_key(user:)
    login_key = user.emergency_login_keys.create(not_valid_after: Time.zone.now + EMERGENCY_LOGIN_KEY_DURATION)
    AuthenticationFallbackMailer.sign_in_fallback(login_key: login_key, email: user.email).deliver_later
  end
end
