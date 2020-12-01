class Publishers::SignIn::BaseSessionsController < Publishers::BaseController
  skip_before_action :authenticate_publisher!
  before_action :sign_out_jobseeker!, only: %i[create]

  def end_session_and_redirect
    flash_message = if session[:publisher_signing_out_for_inactivity]
                      { notice: I18n.t("messages.access.publisher_signed_out_for_inactivity", duration: timeout_period_as_string) }
                    else
                      { success: I18n.t("messages.access.publisher_signed_out") }
                    end
    session.destroy
    redirect_to new_identifications_path, flash_message
  end

private

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
end
