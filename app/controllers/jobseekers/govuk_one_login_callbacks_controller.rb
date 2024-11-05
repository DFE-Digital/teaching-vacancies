class Jobseekers::GovukOneLoginCallbacksController < Devise::OmniauthCallbacksController
  include Jobseekers::GovukOneLogin::Errors
  # Devise redirects response from Govuk One Login to this method.
  # The request parameters contain the response from Govuk One Login from the user authentication through their portal.
  def openid_connect
    if jobseeker_signed_in?
      flash[:alert] = I18n.t("jobseekers.govuk_one_login_callbacks.openid_connect.already_signed_in")
      redirect_to root_path and return
    end

    govuk_one_login_user = Jobseekers::GovukOneLogin::UserFromAuthResponse.call(params, session)
    return error_redirect unless govuk_one_login_user

    session[:govuk_one_login_id_token] = govuk_one_login_user.id_token

    jobseeker = match_jobseeker_from_govuk_one_login(govuk_one_login_user)

    session.delete(:govuk_one_login_state)
    session.delete(:govuk_one_login_nonce)

    if jobseeker
      sign_out_except(:jobseeker)
      trigger_jobseeker_successful_govuk_one_login_sign_in_event(jobseeker)
      sign_in_and_redirect jobseeker
    end
  rescue GovukOneLoginError => e
    trigger_jobseeker_failed_govuk_one_login_sign_in_event(jobseeker)
    Rails.logger.error(e.message)
    error_redirect
  end

  private

  def match_jobseeker_from_govuk_one_login(govuk_one_login_user)
    id = govuk_one_login_user.id
    email = govuk_one_login_user.email
    jobseeker = Jobseeker.find_from_govuk_one_login(id:, email:)

    if jobseeker.nil? # Completely new user
      session[:newly_created_user] = { value: "true", path: "/", expires: 1.hour.from_now }
      jobseeker = Jobseeker.create_from_govuk_one_login(id:, email:)
    elsif jobseeker.govuk_one_login_id.nil? # User exists but is their first time signing-in with OneLogin
      session[:user_exists_first_log_in] = { value: "true", path: "/", expires: 1.hour.from_now }
      jobseeker.update!(govuk_one_login_id: id)
    elsif jobseeker.email != email # User changed their email in OneLogin after having already signed in with us
      jobseeker.update_email_from_govuk_one_login!(email)
    end

    jobseeker
  end

  def error_redirect
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
