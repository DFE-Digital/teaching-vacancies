class HiringStaff::IdentificationsController < HiringStaff::BaseController
  skip_before_action :check_user_last_activity_at
  skip_before_action :check_session, only: %i[new create request_email_sign_in]
  skip_before_action :check_terms_and_conditions, only: %i[new create request_email_sign_in]
  skip_before_action :verify_authenticity_token, only: %i[create]

  before_action :redirect_signed_in_users

  def new
    if AuthenticationFallback.enabled?
      render :authentication_fallback
    end
  end

  def request_email_sign_in
    raise unless AuthenticationFallback.enabled?
  end

  def create
    redirect_to new_dfe_path
  end

  def redirect_signed_in_users
    return redirect_to school_path if session.key?(:urn)
  end
end
