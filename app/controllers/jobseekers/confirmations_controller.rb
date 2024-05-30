class Jobseekers::ConfirmationsController < Devise::ConfirmationsController
  #
  # Overriden Devise methods.
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

  # Completely replaces the Devise definition
  # Takes user to "check your email" page even if they introduced the wrong email address.
  # This is to avoid an attacker discovering registered email addresses on the service through this form.
  def create
    if resource_params[:email].blank?
      self.resource = Jobseeker.new
      resource.errors.add(:email, :blank)
      return render(:new)
    end
    self.resource = Jobseeker.send_confirmation_instructions(resource_params)

    session[:jobseeker_id] = resource.id if resource # Ensures that the jobseeker is identified on following pages.
    flash[:success] = t("jobseekers.registrations.check_your_email.resent_email_confirmation")
    respond_with({}, location: jobseekers_check_your_email_path)
  end

  protected

  def after_confirmation_path_for(_resource_name, resource)
    sign_in(resource)
    flash.delete(:notice)
    confirmation_jobseekers_account_path
  end
end
