class Jobseekers::ConfirmationsController < Devise::ConfirmationsController
  after_action :remove_devise_flash!, only: %i[create]

  def show
    super { |jobseeker| skip_errors_when_already_confirmed(jobseeker) }
  end

  protected

  def after_confirmation_path_for(resource_name, _resource)
    sign_in_on_first_confirmation
    if signed_in?(resource_name)
      stored_location_for(resource_name) || jobseeker_root_path
    else
      new_session_path(resource_name)
    end
  end

  def after_resending_confirmation_instructions_path_for(_resource)
    jobseekers_check_your_email_path
  end

  # Skip dead-end 'Your request is no longer valid' page when account is already confirmed
  #
  # We have a hypothesis that email clients automatically click confirmation links before users get to them
  # in order to preload the images, and that this may be the reason some users always see the error page.
  def skip_errors_when_already_confirmed(jobseeker)
    return unless jobseeker.errors.added?(:email, :already_confirmed)

    jobseeker.errors.delete(:email, :already_confirmed)
    session[:require_auth_after_confirming] = true
  end

  # Sign in users the first time they follow the account confirmation link
  #
  # Prevent account confirmation links in emails from becoming everlasting password-equivalents
  # by requiring users to authenticate if the link is followed again.
  def sign_in_on_first_confirmation
    if session.delete(:require_auth_after_confirming) == true
      request_event.trigger(:jobseeker_email_confirmed)
      sign_in(resource)
    else
      # Track whether we need this custom code or not
      request_event.trigger(:jobseeker_email_confirmed_redundantly, jobseeker_id: StringAnonymiser.new(resource.id))
    end
  end
end
