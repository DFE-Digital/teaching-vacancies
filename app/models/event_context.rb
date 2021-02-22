class EventContext < ActiveSupport::CurrentAttributes
  attribute :request_event

  def trigger_event(event_type, data = {})
    return unless Rails.configuration.analytics.key?(data[:table_name].to_sym)

    event.trigger(event_type, data)
  end

  private

  def event
    request_event || Event.new
  end
end
