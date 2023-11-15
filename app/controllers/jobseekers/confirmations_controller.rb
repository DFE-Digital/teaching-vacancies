class Jobseekers::ConfirmationsController < Devise::ConfirmationsController
  # Overriden Devise method.
  #
  # Introduces a middle step to confirm the user account after following the email confirmation link.
  # This resolves issues with some email cloud providers (Outlook) security checks consuming the confirmation token and
  # and then redirecting the user to the page, causing the user to land at a "link expired" error page.
  def show
    return super if request.method == "POST" # When clicking "Confirm" on the confirmation page, handles it to Devise.

    # When landing on the confirmation page from the email link.
    return not_found unless params[:confirmation_token].present?

    if (user = Jobseeker.find_by(confirmation_token: params[:confirmation_token]))
      user.needs_email_confirmation? ? render(:show) : render(:already_confirmed)
    else
      not_found
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
