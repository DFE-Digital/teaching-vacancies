class Jobseekers::AccountMailer < Jobseekers::BaseMailer
  include Jobseekers::DeviseEmails

  def account_closed(record, _opts = {})
    send_devise_email(
      jobseeker: record,
    )
  end

  def inactive_account(record, _opts = {})
    send_devise_email(
      jobseeker: record,
    )
  end

  def request_account_transfer(record, _opts = {})
    send_devise_email(
      jobseeker: record,
      token: record.account_merge_confirmation_code,
    )
  end
end
