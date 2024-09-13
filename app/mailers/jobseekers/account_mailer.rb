class Jobseekers::AccountMailer < Jobseekers::BaseMailer
  include Jobseekers::DeviseEmails

  def account_closed(record, _opts = {})
    send_email(
      jobseeker: record,
      template: template,
    )
  end

  def inactive_account(record, _opts = {})
    send_email(
      jobseeker: record,
      template: template,
    )
  end

  def request_account_transfer(record, _opts = {})
    send_email(
      jobseeker: record,
      template: template,
      token: record.account_merge_confirmation_code,
    )
  end
end
