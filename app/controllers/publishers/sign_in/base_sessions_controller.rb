class Publishers::SignIn::BaseSessionsController < Publishers::BaseController
  PUBLISHER_SESSION_KEYS = %i[
    publisher_id_token
    publisher_oid
    publisher_multiple_organisations
    organisation_urn
    organisation_uid
    organisation_la_code
  ].freeze

  skip_before_action :authenticate_publisher!
  before_action :sign_out_jobseeker!, only: %i[create]

  def end_session_and_redirect
    flash_message = if session[:publisher_signing_out_for_inactivity]
                      { notice: t("messages.access.publisher_signed_out_for_inactivity", duration: timeout_period_as_string) }
                    else
                      { success: t("messages.access.publisher_signed_out") }
                    end
    clear_publisher_session!
    redirect_to new_identifications_path, flash_message
  end

  private

  def clear_publisher_session!
    PUBLISHER_SESSION_KEYS.each { |key| session.delete(key) }
  end

  def sign_out_jobseeker!
    sign_out(:jobseeker)
  end

  def updated_session_details
    if session[:organisation_urn].present?
      "Updated session with URN #{session[:organisation_urn]}"
    elsif session[:organisation_uid].present?
      "Updated session with UID #{session[:organisation_uid]}"
    elsif session[:organisation_la_code].present?
      "Updated session with LA_CODE #{session[:organisation_la_code]}"
    end
  end

  def trigger_sign_in_event(success_or_failure, sign_in_type, publisher_oid = nil)
    request_event.trigger(
      :publisher_sign_in_attempt,
      user_anonymised_publisher_id: StringAnonymiser.new(publisher_oid),
      success: success_or_failure == :success,
      sign_in_type: sign_in_type,
    )
  end
end
