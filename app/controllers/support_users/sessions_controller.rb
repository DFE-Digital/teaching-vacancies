class SupportUsers::SessionsController < Devise::SessionsController
  include ReturnPathTracking::Helpers

  layout "application_supportal"

  def new
    if (login_failure = params[:login_failure])
      # :nocov:
      flash.now[:alert] = t("devise.failure.#{login_failure}")
      # :nocov:
    end

    store_return_location(support_user_root_path, scope: :support_user) unless redirected?
  end
end
