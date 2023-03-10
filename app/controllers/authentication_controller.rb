# This becomes the superclass of all Devise controllers
class AuthenticationController < ApplicationController
  private

  def sign_out_except(scope)
    %i[
      jobseeker
      publisher
      support_user
    ].each do |s|
      next if s == scope

      clear_extra_publisher_session_entries if s == :publisher
      sign_out(s)
    end
  end

  def clear_extra_publisher_session_entries
    session.delete(:publisher_id)
    session.delete(:publisher_organisation_id)
    session.delete(:visited_new_features_page)
    session.delete(:visited_application_feature_reminder_page)

    session[:publisher_dsi_token_hint] = session.delete(:publisher_dsi_token)
  end

  def trigger_jobseeker_sign_in_event(success_or_failure, errors = nil)
    event = DfE::Analytics::Event.new
      .with_type(:jobseeker_sign_in_attempt)
      .with_request_details(request)
      .with_response_details(response)
      .with_user(current_user)
      .with_data(
        email_identifier: StringAnonymiser.new(params.dig(:jobseeker, :email)),
        success: success_or_failure == :success,
        errors: errors,
      )

    DfE::Analytics::SendEvents.do([event])

    request_event.trigger(
      :jobseeker_sign_in_attempt,
      email_identifier: StringAnonymiser.new(params.dig(:jobseeker, :email)),
      success: success_or_failure == :success,
      errors: errors,
    )
  end

  def trigger_successful_publisher_sign_in_event(sign_in_type, publisher_oid = nil)
    event = DfE::Analytics::Event.new
      .with_type(:successful_publisher_sign_in_attempt)
      .with_request_details(request)
      .with_response_details(response)
      .with_user(current_user)
      .with_data(user_anonymised_publisher_id: StringAnonymiser.new(publisher_oid), sign_in_type: sign_in_type)

    DfE::Analytics::SendEvents.do([event])

    request_event.trigger(
      :successful_publisher_sign_in_attempt,
      user_anonymised_publisher_id: StringAnonymiser.new(publisher_oid),
      sign_in_type: sign_in_type,
    )
  end

  def trigger_successful_support_user_sign_in_event(sign_in_type, oid = nil)
    request_event.trigger(
      :successful_support_user_sign_in_attempt,
      user_anonymised_support_user_id: StringAnonymiser.new(oid),
      sign_in_type: sign_in_type,
    )
  end

  def trigger_failed_dsi_sign_in_event(sign_in_type, oid = nil)
    event = DfE::Analytics::Event.new
      .with_type(:failed_dsi_sign_in_attempt)
      .with_request_details(request)
      .with_response_details(response)
      .with_user(current_user)
      .with_data(user_anonymised_id: StringAnonymiser.new(oid), sign_in_type: sign_in_type)

    DfE::Analytics::SendEvents.do([event])

    request_event.trigger(
      :failed_dsi_sign_in_attempt,
      user_anonymised_id: StringAnonymiser.new(oid),
      sign_in_type: sign_in_type,
    )
  end
end
