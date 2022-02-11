class Jobseekers::SessionsController < Devise::SessionsController
  include ReturnPathTracking::Helpers

  def new
    if (login_failure = params[:login_failure])
      alert_text = t("devise.failure.#{login_failure}")
      flash.now[:alert] = alert_text
      trigger_jobseeker_sign_in_event(:failure, alert_text)
    end

    super do
      unless redirected?
        store_return_location(jobseeker_root_path, scope: :jobseeker)
        session[:after_sign_in] = true
      end
    end
  end

  def create
    if sign_in_params.values.any?(&:blank?)
      redirect_to new_jobseeker_session_path(login_failure: :blank, redirected: redirected?)
      return
    end

    sign_out_publisher!

    super do
      trigger_jobseeker_sign_in_event(:success)

      if current_jobseeker.account_closed?
        Jobseekers::ReactivateAccount.reactivate(current_jobseeker)
        store_return_location(jobseeker_root_path, scope: :jobseeker)
      end
    end
  end

  private

  def auth_options
    super.merge(recall: "warden#jobseeker_failed_login")
  end
end
