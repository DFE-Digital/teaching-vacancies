class HiringStaff::IdentificationsController < HiringStaff::BaseController
  EMERGENCY_LOGIN_KEY_DURATION = 10.minutes

  skip_before_action :check_user_last_activity_at
  skip_before_action :check_session, only: %i[new create check_your_email choose_org]
  skip_before_action :check_terms_and_conditions, only: %i[new create check_your_email choose_org]
  skip_before_action :verify_authenticity_token, only: %i[create]

  before_action :redirect_signed_in_users
  before_action :check_flag, only: %i[check_your_email choose_org]

  def new
    if AuthenticationFallback.enabled?
      render :authentication_fallback
    end
  end

  def create
    redirect_to new_dfe_path
  end

  def check_your_email
    user = User.find_by(email: params.dig(:user, :email).downcase.strip)
    send_login_key(user: user) if user
  end

  def choose_org
    @schools = get_schools_from_login_key
    # TODO: include school_groups here when we have implemented school groups/trusts/LAs
  end

  private

  def get_schools_from_login_key
    params_login_key = params.permit(:login_key)['login_key']
    if params_login_key
      login_key = EmergencyLoginKey.find(params_login_key)
      user = login_key&.user_id ? User.find(login_key.user_id) : nil
    end
    schools = []
    user&.dsi_data&.dig('school_urns')&.each do |urn|
      schools.push SchoolPresenter.new(School.where(urn: urn)).first
    end
    schools.compact
  end

  def send_login_key(user:)
    login_key = user.emergency_login_keys.create(not_valid_after: Time.zone.now + EMERGENCY_LOGIN_KEY_DURATION)
    AuthenticationFallbackMailer.sign_in_fallback(login_key: login_key, email: user.email).deliver_later
  end

  def redirect_signed_in_users
    return redirect_to school_path if session.key?(:urn)
  end

  def check_flag
    redirect_to new_identifications_path unless AuthenticationFallback.enabled?
  end
end
