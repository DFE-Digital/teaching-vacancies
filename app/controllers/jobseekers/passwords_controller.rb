class Jobseekers::PasswordsController < Devise::PasswordsController
  before_action :set_jobseeker_from_token, only: %i[edit update]
  before_action :check_reset_password_token, only: %i[edit]
  after_action :remove_devise_notice_flash!, only: %i[create]

protected

  def reset_password_token
    Devise.token_generator.digest(resource_class, :reset_password_token, params[:reset_password_token] || params[resource_name][:reset_password_token])
  end

  def set_jobseeker_from_token
    @jobseeker_from_token = Jobseeker.find_by(reset_password_token: reset_password_token)
  end

  def check_reset_password_token
    render :expired_token if @jobseeker_from_token&.reset_password_sent_at&.before?(2.hours.ago)
  end

  def after_sending_reset_password_instructions_path_for(_resource)
    jobseekers_check_your_email_password_path
  end

  def after_resetting_password_path_for(resource)
    sign_in(resource)
    jobseekers_saved_jobs_path
  end
end
