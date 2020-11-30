class Jobseekers::RegistrationsController < Devise::RegistrationsController
  after_action :replace_devise_notice_flash_with_success!, only: %i[destroy update]
  after_action :remove_devise_notice_flash!, only: %i[create]

  def check_your_email; end

protected

  def after_inactive_sign_up_path_for(_resource)
    jobseekers_check_your_email_path
  end
end
