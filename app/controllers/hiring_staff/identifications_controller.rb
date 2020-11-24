class HiringStaff::IdentificationsController < HiringStaff::BaseController
  skip_before_action :check_user_last_activity_at
  skip_before_action :check_session, only: %i[new create]
  skip_before_action :check_terms_and_conditions, only: %i[new create]
  skip_before_action :verify_authenticity_token, only: %i[create]

  before_action :redirect_signed_in_publishers, only: %i[new create]
  before_action :redirect_for_fallback_authentication, only: %i[new create]

  def new; end

  def create
    redirect_to new_dfe_path
  end

  def redirect_for_fallback_authentication
    redirect_to new_auth_email_path if AuthenticationFallback.enabled?
  end
end
