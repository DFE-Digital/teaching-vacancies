class Jobseekers::ConfirmationsController < Devise::ConfirmationsController
  after_action :remove_devise_flash!, only: %i[create]
  after_action :replace_devise_notice_flash_with_success!, only: %i[show]

protected

  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource)
    stored_location_for(resource_name) || jobseekers_saved_jobs_path
  end

  def after_resending_confirmation_instructions_path_for(_resource)
    jobseekers_check_your_email_path
  end
end
