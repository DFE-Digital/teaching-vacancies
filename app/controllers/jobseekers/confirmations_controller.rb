class Jobseekers::ConfirmationsController < Devise::ConfirmationsController
  def show
    super if request.method == "POST"
  end

  protected

  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource)
    request_event.trigger(:jobseeker_email_confirmed)
    flash.delete(:notice)
    stored_location_for(resource_name) || confirmation_jobseekers_account_path
  end

  def after_resending_confirmation_instructions_path_for(_resource)
    jobseekers_check_your_email_path
  end
end
