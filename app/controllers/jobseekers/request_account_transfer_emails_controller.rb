class Jobseekers::RequestAccountTransferEmailsController < Jobseekers::BaseController
  def new
    @request_account_transfer_email_form = Jobseekers::RequestAccountTransferEmailForm.new
  end

  def create
    @request_account_transfer_email_form = Jobseekers::RequestAccountTransferEmailForm.new(request_account_transfer_email_form_params.merge({ current_jobseeker_email: current_jobseeker.email }))

    if @request_account_transfer_email_form.valid?
      jobseeker = Jobseeker.find_by(email: @request_account_transfer_email_form.email.downcase)
      if jobseeker
        jobseeker.generate_merge_verification_code
        Jobseekers::AccountMailer.request_account_transfer(jobseeker).deliver_now
      end

      success_message = @request_account_transfer_email_form.email_resent ? t(".success") : nil
      redirect_to new_jobseekers_account_transfer_path(email: @request_account_transfer_email_form.email), success: success_message
    else
      render :new
    end
  end

  def request_account_transfer_email_form_params
    params.require(:jobseekers_request_account_transfer_email_form).permit(:email, :email_resent)
  end
end
