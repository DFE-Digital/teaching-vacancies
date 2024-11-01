class Jobseekers::RegistrationsController < Devise::RegistrationsController
  include RecaptchaChecking

  helper_method :password_update?

  prepend_before_action :check_captcha, only: [:create]

  before_action :check_password_difference, only: %i[update]
  before_action :check_new_password_presence, only: %i[update]
  before_action :check_email_difference, only: %i[update]
  after_action :set_correct_update_message, only: %i[update]

  def confirm_destroy
    @close_account_feedback_form = Jobseekers::CloseAccountFeedbackForm.new
  end

  def destroy
    Jobseekers::CloseAccount.new(current_jobseeker, close_account_feedback_form_params).call
    sign_out(:jobseeker)
    redirect_to root_path, success: t(".success")
  end

  def check_your_email
    flash.delete(:notice)
    @resource = Jobseeker.find_by(id: session[:jobseeker_id])
  end

  protected

  def check_password_difference
    return unless password_update?
    return unless params[resource_name][:password].present?
    return unless params[resource_name][:current_password] == params[resource_name][:password]

    render_resource_with_error(:password, :same_as_old)
  end

  def check_new_password_presence
    return unless password_update?
    return unless params[resource_name][:current_password].present?
    return if params[resource_name][:password].present?

    render_resource_with_error(:password, :too_short)
  end

  def check_email_difference
    return if password_update?
    return unless params[resource_name][:email].present?
    return unless params[resource_name][:email] == current_jobseeker.email

    render_resource_with_error(:email, :same_as_old)
  end

  def render_resource_with_error(field, error)
    self.resource = resource_class.new
    resource.errors.add(field, error)
    render :edit
  end

  def password_update?
    params[:password_update] == "true" || params.dig(resource_name, :password)
  end

  def set_correct_update_message
    flash[:notice] = t("devise.passwords.updated") if flash[:notice] && params.dig(resource_name, :password)
  end

  def after_inactive_sign_up_path_for(resource)
    session[:jobseeker_id] = resource.id
    jobseekers_check_your_email_path
  end

  def after_update_path_for(_resource)
    jobseekers_account_path
  end

  def close_account_feedback_form_params
    params.require(:jobseekers_close_account_feedback_form)
          .permit(:close_account_reason, :close_account_reason_comment)
  end

  # https://github.com/heartcombo/devise/wiki/How-To:-Use-Recaptcha-with-Devise
  def check_captcha
    return if recaptcha_is_valid?

    self.resource = resource_class.new sign_up_params
    resource.validate # Look for any other validation errors besides reCAPTCHA
    set_minimum_password_length

    respond_with_navigational(resource) do
      @show_recaptcha = true
      resource.errors.add(:recaptcha, t("recaptcha.error"))
      render :new
    end
  end
end
