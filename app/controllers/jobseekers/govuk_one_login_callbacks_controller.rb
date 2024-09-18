class Jobseekers::GovukOneLoginCallbacksController < Devise::OmniauthCallbacksController
  include Jobseekers::GovukOneLogin::Errors
  # Devise redirects response from Govuk One Login to this method.
  # The request parameters contain the response from Govuk One Login from the user authentication through their portal.

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def openid_connect
    if (govuk_one_login_user = Jobseekers::GovukOneLogin::UserFromAuthResponse.call(params, session))
      session[:govuk_one_login_id_token] = govuk_one_login_user.id_token

      jobseeker = Jobseeker.find_by("lower(email) = ?", govuk_one_login_user.email.downcase)

      if jobseeker.nil?
        session[:newly_created_user] = { value: "true", path: "/", expires: 1.hour.from_now }
        jobseeker = Jobseeker.create_from_govuk_one_login(email: govuk_one_login_user.email, govuk_one_login_id: govuk_one_login_user.id)
      elsif jobseeker.govuk_one_login_id.nil?
        session[:user_exists_first_log_in] = { value: "true", path: "/", expires: 1.hour.from_now }
        jobseeker.update(govuk_one_login_id: govuk_one_login_user.id)
      end

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
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

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
    if user_signed_in_from_quick_apply_link?(stored_location)
      stored_location
    elsif session[:newly_created_user]
      session.delete(:newly_created_user)
      account_not_found_jobseekers_account_path
    elsif session[:user_exists_first_log_in]
      session.delete(:user_exists_first_log_in)
      account_found_jobseekers_account_path
    else
      jobseekers_job_applications_path
    end
  end

  def user_signed_in_from_quick_apply_link?(stored_location)
    stored_location&.include?("job_application/new")
  end
end
