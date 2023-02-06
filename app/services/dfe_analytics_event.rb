class DfeAnalyticsEvent < RequestEvent
  def trigger(event_type, event_data = {})
    fail_safe do
      event_data = base_data.merge(
        type: event_type,
        occurred_at: occurred_at(event_data),
        data: data.push(*event_data.map { |key, value| { key: key.to_s, value: formatted_value(value) } }),
      )

      SendDfeAnalyticsEventJob.perform_now(event_data)
    end
  end

  private

  def request_data
    { request: request }
  end

  def response_data
    { response: response }
  end

  def user_data
    { user: super }
  end
end
