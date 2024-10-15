class Jobseekers::GovukOneLoginCallbacksController < Devise::OmniauthCallbacksController
  include Jobseekers::GovukOneLogin::Errors
  # Devise redirects response from Govuk One Login to this method.
  # The request parameters contain the response from Govuk One Login from the user authentication through their portal.

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def openid_connect
    if (govuk_one_login_user = Jobseekers::GovukOneLogin::UserFromAuthResponse.call(params, session))
      session[:govuk_one_login_id_token] = govuk_one_login_user.id_token
      jobseeker = Jobseeker.find_by(govuk_one_login_id: govuk_one_login_user.id) ||
                  Jobseeker.find_by(email: govuk_one_login_user.email) # Pre-migration to GovUK One Login Jobseeker still non-linked with a One Login account.

      # Completely new user
      if jobseeker.nil?
        session[:newly_created_user] = { value: "true", path: "/", expires: 1.hour.from_now }
        jobseeker = Jobseeker.create_from_govuk_one_login(email: govuk_one_login_user.email, govuk_one_login_id: govuk_one_login_user.id)
      # User exists but is their first time signing-in with OneLogin
      elsif jobseeker.govuk_one_login_id.nil?
        session[:user_exists_first_log_in] = { value: "true", path: "/", expires: 1.hour.from_now }
        jobseeker.update(govuk_one_login_id: govuk_one_login_user.id)
      # User changed their email in OneLogin after having already signed in with us
      elsif jobseeker.email != govuk_one_login_user.email
        jobseeker.update(email: govuk_one_login_user.email)
      end

      session.delete(:govuk_one_login_state)
      session.delete(:govuk_one_login_nonce)

      if jobseeker
        sign_out_except(:jobseeker)
        sign_in_and_redirect jobseeker
      end
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

    flash[:alert] = I18n.t("jobseekers.govuk_one_login_callbacks.openid_connect.error")
    redirect_to root_path
  end

  # Devise method to redirect the user after sign in.
  # We need to build our own logic to redirect the user to the correct pages.
  def after_sign_in_path_for(resource)
    stored_location = stored_location_for(resource)
    if redirect_to_location?(stored_location)
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

  def redirect_to_location?(stored_location)
    return false if stored_location.blank?

    stored_location.include?("/job_application/new") || # Signed-in from a quick apply link
      stored_location.include?("/saved_job/") || # Signed-in from a vacancy page save/unsave action.
      stored_location.include?("/jobseekers/subscriptions") # Signed-in from a job alert email link.
  end
end
