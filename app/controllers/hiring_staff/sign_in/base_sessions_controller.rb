class HiringStaff::SignIn::BaseSessionsController < HiringStaff::BaseController
  skip_before_action :check_user_last_activity_at

  def end_session_and_redirect
    flash_message = if session[:signing_out_for_inactivity]
      { notice: I18n.t('messages.access.signed_out_for_inactivity', duration: timeout_period_as_string) }
                    else
      { success: I18n.t('messages.access.signed_out') }
                    end
    session.destroy
    redirect_to new_identifications_path, flash_message
  end
end
