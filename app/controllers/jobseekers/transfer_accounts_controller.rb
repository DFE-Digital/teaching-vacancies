class Jobseekers::TransferAccountsController < Jobseekers::BaseController
  def new
    @transfer_accounts_form = Jobseekers::TransferAccountForm.new
  end
end
