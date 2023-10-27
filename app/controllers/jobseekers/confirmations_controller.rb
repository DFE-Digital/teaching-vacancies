class Jobseekers::ConfirmationsController < Devise::ConfirmationsController
  # Overriden Devise method.
  #
  # Introduces a middle step to confirm the user account after following the email confirmation link.
  #
  # Instead of being directly confirmed when following the link, the users will be queried to press a 'Confirm' button
  # that will trigger the user confirmation.
  #
  # This solves issues with some email cloud providers (Outlook) introducing a security messure that proxies any https
  # link for security checks. That security check was consuming the user token and then redirecting the user to a
  # invalid link page.
  def show
    if request.method == "POST" # When submitting confirmation from #show view.
      super # Calls original Devise method to attempt to confirm the user.
    else # When landing on the confirmation page from the email link.
      user = Jobseeker.find_by(confirmation_token: params[:confirmation_token])
      not_found unless user.present? # Doesn't allow the user to view the confirmation page unless landing with a valid token.
    end
  end

  protected

  def after_confirmation_path_for(_resource_name, resource)
    sign_in(resource)
    request_event.trigger(:jobseeker_email_confirmed)
    flash.delete(:notice)
    confirmation_jobseekers_account_path
  end

  def after_resending_confirmation_instructions_path_for(_resource)
    jobseekers_check_your_email_path
  end
end
