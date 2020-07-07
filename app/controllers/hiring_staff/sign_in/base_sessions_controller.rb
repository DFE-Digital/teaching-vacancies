class HiringStaff::SignIn::BaseSessionsController < HiringStaff::BaseController
  skip_before_action :check_user_last_activity_at

  def end_session_and_redirect
    if session[:signing_out_for_inactivity]
      flash_message = { notice: I18n.t(
        'messages.access.signed_out_for_inactivity',
        duration: timeout_period_as_string) }
    else
      flash_message = { success: I18n.t('messages.access.signed_out') }
    end
    session.destroy
    redirect_to new_identifications_path, flash_message
  end

  def redirect_to_organisation_path
    if current_organisation.is_a?(School)
      redirect_to organisation_path
    else
      redirect_to school_group_temporary_path
    end
  end
end
