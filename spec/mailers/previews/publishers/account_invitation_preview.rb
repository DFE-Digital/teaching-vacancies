class Publishers::AccountInvitationPreview < ActionMailer::Preview
  def invite_user
    Publishers::AccountInvitationMailer.invite_user(
      contact_email: "new.contact@example.com",
      publisher_email: "publisher@school.edu"
    )
  end
end