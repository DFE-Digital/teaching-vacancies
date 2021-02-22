class EventContext < ActiveSupport::CurrentAttributes
  attribute :request_event

  def trigger_event(...)
    event.trigger(...)
  end

  private

  def event
    request_event || Event.new
  end
end
