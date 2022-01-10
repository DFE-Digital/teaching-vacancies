class Jobseekers::SessionsController < Devise::SessionsController
  before_action :sign_out_publisher!, only: %i[create]
  before_action :render_resource_with_errors, only: %i[new]
  before_action :check_if_access_locked, only: %i[new]
  after_action only: %i[create] do
    trigger_jobseeker_sign_in_event(:success)
    reactivate_account_if_closed
  end

  AUTHENTICATION_FAILURE_MESSAGES = %w[
    invalid not_found_in_database last_attempt
  ].map { |error| I18n.t("devise.failure.#{error}") }.freeze

  def destroy
    session.delete(:jobseeker_return_to)
    super
  end

  private

  def render_resource_with_errors
    self.resource = resource_class.new
    if params[:action] == "create" && sign_in_form.invalid?
      sign_in_form.errors.each { |error| resource.errors.add(error.attribute, error.type) }
    elsif AUTHENTICATION_FAILURE_MESSAGES.include?(flash[:alert])
      resource.errors.add(:email, flash[:alert])
      resource.errors.add(:password, "")
    else
      return
    end
    trigger_jobseeker_sign_in_event(:failure, resource.errors)
    clear_flash_and_render(:new)
  end

  def sign_in_form
    @sign_in_form ||= Jobseekers::SignInForm.new(sign_in_params)
  end

  def check_if_access_locked
    clear_flash_and_render(:locked) if resource_class.find_by(email: sign_in_params[:email])&.access_locked?
  end

  def clear_flash_and_render(view)
    flash.clear
    render view
  end

  def trigger_jobseeker_sign_in_event(success_or_failure, errors = nil)
    request_event.trigger(
      :jobseeker_sign_in_attempt,
      email_identifier: StringAnonymiser.new(params[:jobseeker][:email]),
      success: success_or_failure == :success,
      errors:,
    )
  end

  def reactivate_account_if_closed
    return unless current_jobseeker.account_closed_on?

    Jobseekers::ReactivateAccount.new(current_jobseeker).call
  end
end
