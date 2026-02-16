class Jobseekers::GovukOneLoginCallbacksController < Devise::OmniauthCallbacksController
  include Jobseekers::GovukOneLogin::Errors

  # Devise redirects response from Govuk One Login to this method.
  # The request parameters contain the response from Govuk One Login from the user authentication through their portal.
  # rubocop:disable Metrics/MethodLength
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
      Jobseekers::ReactivateAccount.reactivate(jobseeker) if jobseeker.account_closed?
      sign_in_and_redirect jobseeker
    end
  rescue GovukOneLoginError => e
    trigger_jobseeker_failed_govuk_one_login_sign_in_event(jobseeker)
    Rails.logger.error(e.message)
    error_redirect
  end
  # rubocop:enable Metrics/MethodLength

  private

  # rubocop:disable Metrics/AbcSize
  def match_jobseeker_from_govuk_one_login(govuk_one_login_user)
    jobseeker = Jobseeker.find_from_govuk_one_login(id: govuk_one_login_user.id, email: govuk_one_login_user.email)

    # Completely new user
    if jobseeker.nil?
      session[:newly_created_user] = { value: "true", path: "/", expires: 1.hour.from_now }
      jobseeker = Jobseeker.create_from_govuk_one_login(id: govuk_one_login_user.id, email: govuk_one_login_user.email)
    # User exists but is their first time signing-in with OneLogin
    elsif jobseeker.govuk_one_login_id.nil?
      session[:user_exists_first_log_in] = { value: "true", path: "/", expires: 1.hour.from_now }
      jobseeker.update!(govuk_one_login_id: govuk_one_login_user.id)
    # User deleted their OneLogin account and created a new one using the same email
    elsif jobseeker.govuk_one_login_id != govuk_one_login_user.id
      previous_id = jobseeker.govuk_one_login_id
      jobseeker.update!(govuk_one_login_id: govuk_one_login_user.id)
      trigger_jobseeker_changed_govuk_one_login_id_event(jobseeker, previous_id)
    # User changed their email in OneLogin after having already signed in with us
    elsif jobseeker.email != govuk_one_login_user.email
      previous_email = jobseeker.email
      if jobseeker.update_email_from_govuk_one_login!(govuk_one_login_user.email)
        trigger_jobseeker_changed_govuk_one_login_email_event(jobseeker, previous_email)
      end
    end

    jobseeker
  end
  # rubocop:enable Metrics/AbcSize

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
      stored_location.include?("/jobs/") || # Signed-in from a job page (in order to download)
      stored_location.include?("/jobseekers/subscriptions") || # Signed-in from a job alert email link.
      stored_location.include?("/self_disclosure/#{Wicked::FIRST_STEP}") || # Signed-in from self-disclosure email link.
      stored_location.include?("/jobseekers/account/email_preferences/edit") || # Signed-in from a peak times email.
      stored_location.include?("/apply") # Signed-in from an apply link on vacancy with uploaded form.
  end

  # These 2 functions are really tricky to write automated tests for
  # :nocov:
  def trigger_jobseeker_changed_govuk_one_login_id_event(jobseeker, previous_id)
    event = DfE::Analytics::Event.new
      .with_type(:jobseeker_changed_govuk_one_login_id)
      .with_request_details(request)
      .with_response_details(response)
      .with_user(jobseeker)
      .with_data(
        hidden_data: { email_identifier: jobseeker&.email,
                       govuk_one_login_id: jobseeker&.govuk_one_login_id,
                       previous_govuk_one_login_id: previous_id },
      )

    DfE::Analytics::SendEvents.do([event])
  end

  def trigger_jobseeker_changed_govuk_one_login_email_event(jobseeker, previous_email)
    event = DfE::Analytics::Event.new
      .with_type(:jobseeker_changed_govuk_one_login_email)
      .with_request_details(request)
      .with_response_details(response)
      .with_user(jobseeker)
      .with_data(
        hidden_data: { email_identifier: jobseeker&.email,
                       govuk_one_login_id: jobseeker&.govuk_one_login_id,
                       previous_email_identifier: previous_email },
      )

    DfE::Analytics::SendEvents.do([event])
  end
  # :nocov:
end
