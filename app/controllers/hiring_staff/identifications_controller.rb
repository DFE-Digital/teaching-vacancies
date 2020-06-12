class HiringStaff::IdentificationsController < HiringStaff::BaseController
  skip_before_action :check_user_last_activity_at
  skip_before_action :check_session, only: %i[new create check_your_email]
  skip_before_action :check_terms_and_conditions, only: %i[new create check_your_email]
  skip_before_action :verify_authenticity_token, only: %i[create]

  before_action :redirect_signed_in_users
  before_action :check_flag, only: %i[check_your_email]

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

  def sign_in_by_email
    
  end

  private

  def send_login_key(user:)
    login_key = user.emergency_login_keys.create(not_valid_after: Time.zone.now + 10.minutes)
    AuthenticationFallbackMailer.sign_in_fallback(login_key: login_key, email: user.email).deliver_later
  end

  def redirect_signed_in_users
    return redirect_to school_path if session.key?(:urn)
  end

  def check_flag
    redirect_to new_identifications_path unless AuthenticationFallback.enabled?
  end
end
