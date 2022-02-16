class Jobseekers::PasswordsController < Devise::PasswordsController
  before_action :ensure_reset_password_period_valid, only: %i[edit update]

  protected

  def ensure_reset_password_period_valid
    token = params[:reset_password_token] || params[resource_name][:reset_password_token]
    self.resource = resource_class.with_reset_password_token(token)

    render :expired_token if resource && !resource.reset_password_period_valid?
  end

  def after_sending_reset_password_instructions_path_for(_resource)
    jobseekers_check_your_email_password_path
  end
end
