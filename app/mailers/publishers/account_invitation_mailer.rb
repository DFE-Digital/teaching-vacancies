class Publishers::AccountInvitationMailer < Publishers::BaseMailer
  include MailerAnalyticsEvents

  def invite_user(contact_email:, publisher_email:)
    @contact_email = contact_email
    @publisher_email = publisher_email
    @publisher = Publisher.find_by(email: publisher_email) # For analytics

    @subject = I18n.t("publishers.account_invitation_mailer.invite_user.subject")

    send_email(to: contact_email, subject: @subject)
  end
end
