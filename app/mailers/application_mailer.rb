class ApplicationMailer < Mail::Notify::Mailer
  helper NotifyViewHelper
  helper OrganisationHelper

  helper_method :uid

  after_action :trigger_email_event

  private

  def trigger_email_event
    email_event.trigger("#{email_event_prefix}_#{action_name}".to_sym, email_event_data)
  end

  def email_event_data
    {}
  end

  def uid
    # Time in milliseconds since epoch. We're assuming that 2 emails don't get sent in the same millisecond.
    # If this assumption isn't safe, then we should encode some other details (e.g email_event_type) to ensure the uid is unique.
    @uid ||= DateTime.current.strftime("%Q")
  end
end
