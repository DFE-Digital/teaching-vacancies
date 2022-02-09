class Jobseekers::AccountMailer < Jobseekers::BaseMailer
  include Jobseekers::DeviseEmails

  def account_closed(record, _opts = {})
    send_email(
      jobseeker: record,
      template: NOTIFY_JOBSEEKER_ACCOUNT_CLOSED_TEMPLATE,
    )
  end

  def inactive_account(record, _opts = {})
    send_email(
      jobseeker: record,
      template: NOTIFY_JOBSEEKER_INACTIVE_ACCOUNT_TEMPLATE,
    )
  end
end
