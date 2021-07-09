class Admins::AccountMailer < Mail::Notify::Mailer
  def account_creation_request(record, _opts = {})
    @template = NOTIFY_ADMIN_ACCOUNT_CREATION_REQUEST_TEMPLATE
    @account_request = record
    @to = t("help.email")

    view_mail(@template, to: @to, subject: t(".subject"))
  end
end
