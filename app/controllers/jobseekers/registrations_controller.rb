class Jobseekers::RegistrationsController < Devise::RegistrationsController
  before_action :check_password_difference, only: %i[update]
  before_action :check_new_password_presence, only: %i[update]
  after_action :replace_devise_notice_flash_with_success!, only: %i[destroy update]
  after_action :remove_devise_notice_flash!, only: %i[create]

  def check_your_email; end

protected

  def check_password_difference
    return unless params[resource_name][:password].present?
    return unless params[resource_name][:current_password] == params[resource_name][:password]

    render_resource_with_error(:password, :same_as_old)
  end

  def check_new_password_presence
    return unless params[resource_name][:current_password].present?
    return if params[resource_name][:password].present?

    render_resource_with_error(:password, :too_short)
  end

  def render_resource_with_error(field, error)
    self.resource = resource_class.new
    resource.errors.add(field, error)
    render :edit
  end

  def after_inactive_sign_up_path_for(_resource)
    jobseekers_check_your_email_path
  end

  def after_update_path_for(_resource)
    jobseekers_account_path
  end
end
