class Publishers::SessionsController < Publishers::BaseController
  protect_from_forgery with: :null_session, only: %i[destroy]

  skip_before_action :authenticate_publisher!, only: %i[destroy]
  skip_before_action :update_publisher_last_activity_at, only: %i[destroy]
  skip_before_action :check_session, only: %i[destroy]
  skip_before_action :check_terms_and_conditions, only: %i[destroy]

  def destroy
    redirect_to logout_endpoint
  end
end
