class SupportUsers::SessionsController < Devise::SessionsController
  include ReturnPathTracking::Helpers

  def new
    if (login_failure = params[:login_failure])
      flash.now[:alert] = t("devise.failure.#{login_failure}")
    end

    store_return_location(support_user_root_path, scope: :support_user) unless redirected?
  end
end
