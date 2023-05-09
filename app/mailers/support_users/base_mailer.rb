class SupportUsers::BaseMailer < ApplicationMailer
  private

  def email_event
    @email_event ||= EmailEvent.new(template, to, uid, support_user: @support_user)
  end

  def dfe_analytics_email_event
    @dfe_analytics_email_event ||= DfE::Analytics::Event.new
      .with_type(email_event_type)
      .with_user(@support_user)
      .with_data(dfe_analytics_event_data)
  end

  def email_event_prefix
    "support_user"
  end
end
