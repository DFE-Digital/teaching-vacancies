##
# Represents events occurring within the application that we are interested in tracking.
#
# At a minimum, an event has a type and a timestamp at which it occurred. It may also have optional
# metadata that describes what occurred in more detail. Events are asynchronously sent to our data
# warehouse using a background job. An instance of `Event` can trigger an arbitrary number of
# events (to allow for potentially expensive computation on initialization of subclasses).
class Event
  TABLE_NAME = "events".freeze

  ##
  # Asynchronously sends an event and its metadata to the data warehouse
  #
  # @param [Symbol, String] event_type The type of event (e.g. `:page_visited`) to trigger
  # @param [Hash{Symbol => Object}] data An optional hash of data to include with the event
  #   (Important: if present, values will be coerced into Strings)
  def trigger(event_type, data = {})
    data = base_data.merge(
      type: event_type,
      occurred_at: Time.now.utc.iso8601(6),
      data: data.map { |key, value| { key: key.to_s, value: value&.to_s } },
    )
    SendEventToDataWarehouseJob.perform_later(TABLE_NAME, data)
  rescue StandardError => e
    Rollbar.error(e)
  end

private

  ##
  # Data to be included with any event (to be overridden as appropriate in subclasses)
  def base_data
    {}
  end
end
