module MailerHelpers
  def last_email
    ActionMailer::Base.deliveries.last
  end

  def delivered_emails
    ActionMailer::Base.deliveries
  end

  def first_link_from_last_mail
    last_email.body.to_s[/\]\((.*)\)/, 1].delete_suffix(")")
  end
end
