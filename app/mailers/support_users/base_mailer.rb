class SupportUsers::BaseMailer < ApplicationMailer
  private

  def email_event
    @email_event ||= EmailEvent.new(template, to, uid, support_user: @support_user)
  end

  def email_event_prefix
    "support_user"
  end
end
