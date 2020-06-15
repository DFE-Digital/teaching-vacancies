class HiringStaff::SessionsController < HiringStaff::BaseController
  protect_from_forgery with: :null_session, only: %i[destroy]

  skip_before_action :check_user_last_activity_at, only: %i[destroy]
  skip_before_action :update_user_last_activity_at, only: %i[destroy]
  skip_before_action :check_session, only: %i[destroy]
  skip_before_action :check_terms_and_conditions, only: %i[destroy]

  def destroy
    redirect_to dsi_logout_url
  end

  private

  def redirect_to_dfe_sign_in
    # This is defined by the class name of our Omniauth strategy
    redirect_to '/auth/dfe'
  end
end
