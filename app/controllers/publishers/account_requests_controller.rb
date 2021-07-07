class Publishers::AccountRequestsController < ApplicationController
  def new
    @account_request_form = Publishers::AccountRequestForm.new
  end

  def create
    @account_request_form = Publishers::AccountRequestForm.new(account_request_form_params)

    if @account_request_form.valid?
      account_request = AccountRequest.create(account_request_form_params)
      Admins::AccountMailer.account_creation_request(account_request).deliver_later
    else
      render :new
    end
  end

  private

  def account_request_form_params
    params.require(:publishers_account_request_form)
          .permit(:full_name, :email, :organisation_name, :organisation_identifier)
  end
end
