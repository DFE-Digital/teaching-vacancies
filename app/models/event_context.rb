class EventContext < ActiveSupport::CurrentAttributes
  attribute :request_event
  attribute :events_suppressed

  # Stop sending events in the current context for the duration of a block
  # (useful for situations where records are updated programatically, e.g. in background jobs,
  # and we don't want to send events)
  def suppress_events
    self.events_suppressed = true
    yield
    self.events_suppressed = false
  end

  def trigger_event(event_type, data = {})
    return if data["table_name"] && !Rails.configuration.analytics.key?(data["table_name"].to_sym)
    return if events_suppressed

    event.trigger(event_type, data)
  end

  def trigger_for_dfe_analytics(event_type, event_data = {})
    return if events_suppressed

    event.trigger_for_dfe_analytics(event_type, event_data)
  end

  private

  def event
    request_event || Event.new
  end
end
