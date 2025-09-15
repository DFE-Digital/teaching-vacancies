class Publishers::MessageNotificationMailer < Publishers::BaseMailer
  include MailerAnalyticsEvents

  def messages_received(publisher:, message_count:)
    @publisher = publisher
    @message_count = message_count
    @subject = I18n.t("publishers.message_notification_mailer.messages_received.subject", count: @message_count)

    send_email(to: publisher.email, subject: @subject)
  end
end
