class EventContext < ActiveSupport::CurrentAttributes
  attribute :request_event
  attribute :events_suppressed

  # Stop sending events in the current context (useful for e.g. background jobs where records are
  # updated programatically)
  def suppress_events!
    self.events_suppressed = true
  end

  def trigger_event(event_type, data = {})
    return unless Rails.configuration.analytics.key?(data[:table_name].to_sym)
    return if events_suppressed

    event.trigger(event_type, data)
  end

  private

  def event
    request_event || Event.new
  end
end
