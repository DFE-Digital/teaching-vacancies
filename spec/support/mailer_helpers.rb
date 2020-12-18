module MailerHelpers
  def delivered_emails
    ActionMailer::Base.deliveries
  end

  def last_email
    delivered_emails.last
  end

  def first_link_from_last_mail
    last_email.body.to_s[/\]\((.*)\)/, 1].delete_suffix(")")
  end
end
