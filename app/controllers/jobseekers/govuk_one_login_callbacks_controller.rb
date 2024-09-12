class Jobseekers::GovukOneLoginCallbacksController < Devise::OmniauthCallbacksController
  include Jobseekers::GovukOneLogin::Errors
  # Devise redirects response from Govuk One Login to this method.
  # The request parameters contain the response from Govuk One Login from the user authentication through their portal.
  def openid_connect
    if (govuk_one_login_user = Jobseekers::GovukOneLogin::UserFromAuthResponse.call(params, session))
      session[:govuk_one_login_id_token] = govuk_one_login_user.id_token

      if existing_jobseeker_first_sign_in_via_one_login(govuk_one_login_user)
        session[:user_exists_first_log_in] = { value: "true", path: "/", expires: 1.hour.from_now }
      end

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
  def after_sign_in_path_for(resource)
    stored_location = stored_location_for(resource)

    if stored_location.include?("job_application/new")
      stored_location
    elsif session[:user_exists_first_log_in]
      session.delete(:user_exists_first_log_in)
      account_found_jobseekers_account_path
    else
      jobseekers_job_applications_path
    end
  end

  def existing_jobseeker_first_sign_in_via_one_login(govuk_one_login_user)
    Jobseeker.find_by(email: govuk_one_login_user.email, govuk_one_login_id: nil)
  end
end
