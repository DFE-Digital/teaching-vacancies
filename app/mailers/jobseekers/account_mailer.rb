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
end
