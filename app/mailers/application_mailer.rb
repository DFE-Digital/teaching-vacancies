class ApplicationMailer < Mail::Notify::Mailer
  helper NotifyViewHelper
  helper OrganisationHelper

  after_action :trigger_email_event

  private

  def email_event_data
    {}
  end

  def trigger_email_event
    email_event.trigger("#{email_event_prefix}_#{action_name}".to_sym, email_event_data)
  end
end
