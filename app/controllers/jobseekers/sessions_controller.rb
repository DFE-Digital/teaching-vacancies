class Jobseekers::SessionsController < Devise::SessionsController
  after_action :replace_devise_notice_flash_with_success!, only: %i[create destroy]
  before_action :sign_out_publisher!, only: %i[create]
  before_action :render_form_with_errors, only: %i[new]

  AUTHENTICATION_FAILURE_MESSAGES = %w[
    invalid not_found_in_database locked last_attempt
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

  def clear_flash_and_render(view)
    flash.clear
    render view
  end
end
