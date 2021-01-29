class Jobseekers::RegistrationsController < Devise::RegistrationsController
  before_action :set_update_password, only: %i[edit update]
  before_action :check_password_difference, only: %i[update]
  before_action :check_new_password_presence, only: %i[update]
  before_action :check_email_difference, only: %i[update]
  after_action :replace_devise_notice_flash_with_success!, only: %i[destroy update]
  after_action :set_correct_update_message, only: %i[update]
  after_action :remove_devise_flash!, only: %i[create update]

  protected

  def check_password_difference
    return unless @update_password
    return unless params[resource_name][:password].present?
    return unless params[resource_name][:current_password] == params[resource_name][:password]

    render_resource_with_error(:password, :same_as_old)
  end

  def check_new_password_presence
    return unless @update_password
    return unless params[resource_name][:current_password].present?
    return if params[resource_name][:password].present?

    render_resource_with_error(:password, :too_short)
  end

  def check_email_difference
    return if @update_password
    return unless params[resource_name][:email].present?
    return unless params[resource_name][:email] == current_jobseeker.email

    render_resource_with_error(:email, :same_as_old)
  end

  def render_resource_with_error(field, error)
    self.resource = resource_class.new
    resource.errors.add(field, error)
    render :edit
  end

  def set_update_password
    @update_password = params[:update_password] == "true" || params[:commit] == t("buttons.update_password")
  end

  def set_correct_update_message
    flash[:notice] = t("devise.passwords.updated") if flash[:notice] && params[:commit] == t("buttons.update_password")
  end

  def after_inactive_sign_up_path_for(_resource)
    jobseekers_check_your_email_path
  end

  def after_update_path_for(resource)
    resource.pending_reconfirmation? ? jobseekers_check_your_email_path : jobseekers_account_path
  end
end
