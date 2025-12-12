class Publishers::AccountInvitationMailer < Publishers::BaseMailer
  include MailerAnalyticsEvents

  def invite_user(contact_email:, publisher_email:)
    template_mail("dd91745e-ff16-4ba8-9de6-fb1aea1cf24c",
                  to: contact_email,
                  personalisation: {
                    publisher_email: publisher_email,
                    link: new_publisher_session_url,
                  })
  end
end
