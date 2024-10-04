class ApplicationMailer < Mail::Notify::Mailer
  helper NotifyViewsHelper
  helper OrganisationsHelper

  helper_method :uid, :utm_campaign

  after_action :trigger_dfe_analytics_email_event

  private

  attr_reader :to

  def trigger_dfe_analytics_email_event
    DfE::Analytics::SendEvents.do([dfe_analytics_email_event])
  end

  def email_event_type
    :"#{email_event_prefix}_#{action_name}"
  end

  def uid
    @uid ||= SecureRandom.uuid
  end

  def utm_campaign
    email_event_type
  end

  def template
    NOTIFY_PRODUCTION_TEMPLATE
  end

  def dfe_analytics_custom_data
    {}
  end

  def dfe_analytics_event_data
    base_data = dfe_analytics_base_data
    base_data[:data].merge!(dfe_analytics_custom_data)
    base_data
  end

  def dfe_analytics_base_data
    {
      data: {
        uid: uid,
        notify_template: template,
      },
      hidden_data: {
        email_identifier: to,
      },
    }
  end
end
