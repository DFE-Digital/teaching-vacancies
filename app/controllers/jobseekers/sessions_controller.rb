class Jobseekers::SessionsController < Devise::SessionsController
  before_action :sign_out_publisher!, only: %i[create]
  before_action :render_form_with_errors, only: %i[new]
  before_action :check_if_access_locked, only: %i[new]
  after_action :replace_devise_notice_flash_with_success!, only: %i[create destroy]

  AUTHENTICATION_FAILURE_MESSAGES = %w[
    invalid not_found_in_database last_attempt
  ].map { |error| I18n.t("devise.failure.#{error}") }.freeze

private

  def render_form_with_errors
    self.resource = JobseekerSignInForm.new(sign_in_params)
    if params[:action] == "create" && resource.invalid?
      clear_flash_and_render(:new)
    elsif AUTHENTICATION_FAILURE_MESSAGES.include?(flash[:alert])
      resource.errors.add(:email, flash[:alert])
      clear_flash_and_render(:new)
    end
  end

  def check_if_access_locked
    clear_flash_and_render(:locked) if resource_class.find_by(email: sign_in_params[:email])&.access_locked?
  end
end
