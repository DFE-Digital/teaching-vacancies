class EventContext < ActiveSupport::CurrentAttributes
  attribute :dfe_analytics_request_event

  def trigger_for_dfe_analytics(event_type, event_data = {})
    return if dfe_analytics_request_event.nil?

    dfe_analytics_request_event.trigger_for_dfe_analytics(event_type, event_data)
  end
end
