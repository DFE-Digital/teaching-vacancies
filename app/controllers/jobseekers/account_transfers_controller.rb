class Jobseekers::AccountTransfersController < Jobseekers::BaseController
  def new
    @account_transfer_form = Jobseekers::AccountTransferForm.new
    @email = params["email"]
  end

  def create
    @account_transfer_form = Jobseekers::AccountTransferForm.new(request_account_transfer_email_form_params)

    if @account_transfer_form.valid?
      # do some stuff to transfer over details
      flash[:success] = "Your account details have been transferred successfully!"
      redirect_to jobseekers_profile_path
    else
      render :new
    end
  end

  private

  def request_account_transfer_email_form_params
    params.require(:jobseekers_account_transfer_form).permit(:account_merge_confirmation_code, :email)
  end
end