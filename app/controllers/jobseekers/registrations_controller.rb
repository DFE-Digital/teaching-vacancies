class Jobseekers::RegistrationsController < Devise::RegistrationsController
  def confirm_destroy
    @close_account_feedback_form = Jobseekers::CloseAccountFeedbackForm.new
  end

  def destroy
    Jobseekers::CloseAccount.new(current_jobseeker, close_account_feedback_form_params).call
    sign_out(:jobseeker)
    redirect_to root_path, success: t(".success")
  end

  protected

  def close_account_feedback_form_params
    params.expect(jobseekers_close_account_feedback_form: %i[close_account_reason close_account_reason_comment])
  end
end
