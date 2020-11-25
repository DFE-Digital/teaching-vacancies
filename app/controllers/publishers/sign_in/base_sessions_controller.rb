class Publishers::SignIn::BaseSessionsController < Publishers::BaseController
  skip_before_action :check_user_last_activity_at

  def end_session_and_redirect
    flash_message = if session[:signing_out_for_inactivity]
                      { notice: I18n.t("messages.access.signed_out_for_inactivity", duration: timeout_period_as_string) }
                    else
                      { success: I18n.t("messages.access.signed_out") }
                    end
    session.destroy
    redirect_to new_identifications_path, flash_message
  end

private

  def updated_session_details
    if session[:urn].present?
      "Updated session with URN #{session[:urn]}"
    elsif session[:uid].present?
      "Updated session with UID #{session[:uid]}"
    elsif session[:la_code].present?
      "Updated session with LA_CODE #{session[:la_code]}"
    end
  end
end
