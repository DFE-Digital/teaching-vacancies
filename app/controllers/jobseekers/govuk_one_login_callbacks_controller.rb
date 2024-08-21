class Jobseekers::GovukOneLoginCallbacksController < Devise::OmniauthCallbacksController
  include Jobseekers::GovukOneLogin::Errors
  # Devise redirects response from Govuk One Login to this method.
  # The request parameters contain the response from Govuk One Login from the user authentication through their portal.
  def openid_connect
    if (govuk_one_login_user = Jobseekers::GovukOneLogin::UserFromAuthResponse.call(params, session))
      session[:govuk_one_login_id_token] = govuk_one_login_user.id_token

      jobseeker = Jobseeker.find_or_create_from_govuk_one_login(email: govuk_one_login_user.email,
                                                                govuk_one_login_id: govuk_one_login_user.id)

      session.delete(:govuk_one_login_state)
      session.delete(:govuk_one_login_nonce)
      sign_in_and_redirect jobseeker if jobseeker
    else
      error_redirect
    end
  rescue GovukOneLoginError => e
    Rails.logger.error(e.message)
    error_redirect
  end

  private

  def error_redirect
    return if jobseeker_signed_in?

    flash[:alert] = "There was a problem signing in. Please try again."
    redirect_to root_path
  end

  # Devise method to redirect the user after sign in.
  # We need to build our own logic to redirect the user to the correct pages.
  def after_sign_in_path_for(_resource)
    jobseekers_job_applications_path
  end
end
