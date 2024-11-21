class Jobseekers::AccountTransfersController < Jobseekers::BaseController
  def new
    @account_transfer_form = Jobseekers::AccountTransferForm.new
    @email = params["email"]
  end

  def create
    @account_transfer_form = Jobseekers::AccountTransferForm.new(request_account_transfer_email_form_params)

    if @account_transfer_form.valid?
      if successfully_transfer_account_data?
        flash[:success] = I18n.t("jobseekers.account_transfers.create.success")
        redirect_to jobseekers_profile_path
      else
        @email = @account_transfer_form.email
        flash[:error] = I18n.t("jobseekers.account_transfers.create.failure")
        render :new
      end
    else
      @email = @account_transfer_form.email
      render :new
    end
  end

  private

  def request_account_transfer_email_form_params
    params.require(:jobseekers_account_transfer_form).permit(:account_merge_confirmation_code, :email)
  end

  def successfully_transfer_account_data?
    Jobseekers::AccountTransfer.new(current_jobseeker, @account_transfer_form.email).call
    true
  rescue Jobseekers::AccountTransfer::AccountTransferError, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    Rails.logger.error("Account transfer failed: #{e.message}")

    if e.respond_to?(:record)
      Rails.logger.error("Account transfer failed on #{e.record.class.name} with ID: #{e.record.id}")
      Rails.logger.error("Validation errors: #{e.record.errors.full_messages.join(', ')}")
    end
    false
  end
end
