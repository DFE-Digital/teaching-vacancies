class ApplicationMailer < Mail::Notify::Mailer
  helper NotifyViewsHelper
  helper OrganisationsHelper

  helper_method :uid, :utm_campaign

  after_action :trigger_email_event

  private

  attr_reader :to

  def trigger_email_event
    email_event.trigger(email_event_type, email_event_data)
  end

  def email_event_data
    {}
  end

  def email_event_type
    "#{email_event_prefix}_#{action_name}".to_sym
  end

  def uid
    @uid ||= SecureRandom.uuid
  end

  def utm_campaign
    email_event_type
  end

  def template
    Rails.configuration.app_role == "sandbox" ? NOTIFY_SANDBOX_TEMPLATE : NOTIFY_PRODUCTION_TEMPLATE
  end
end
