module MailerHelpers
  def last_email
    ActionMailer::Base.deliveries.last
  end

  def delivered_emails
    ActionMailer::Base.deliveries
  end

  def devise_token_from_last_mail(token_name)
    last_email.body.to_s[/#{token_name}_token=(\w*)/, 1]
  end
end
