##
# Represents events occurring within the application that we are interested in tracking.
#
# At a minimum, an event has a type and a timestamp at which it occurred. It may also have optional
# metadata that describes what occurred in more detail.
class Event
  TABLE_NAME = "events".freeze

  def trigger_for_dfe_analytics(event_type, event_data = {})
    fail_safe do
      dfe_analytics_event = DfE::Analytics::Event.new
        .with_type(event_type)
        .with_data(base_data.merge(event_data))
        .with_request_details(request)
        .with_response_details(response)
        .with_user(current_jobseeker)

      DfE::Analytics::SendEvents.do([dfe_analytics_event])
    end
  end

  private

  ##
  # Data to be included with any event (to be overridden as appropriate in subclasses)
  def base_data
    {}
  end

  ##
  # Data to be included in the data struct for any event (to be overridden as appropriate in subclasses)
  def data
    []
  end

  ##
  # For json objects or hashes passed to Event#trigger as values in the `data` param, such as Feedback#search_criteria,
  # we should format these as json for BigQuery, rather than strings, for easier manipulation by Performance Analysis.
  # Floats and Integers should remain as they are. Do not pass Arrays to BigQuery without converting them to string:
  # otherwise, it will give the error "Array specified for non repeated field" when the array has length of 1.
  # @param [Object] value Any value in the data passed to the event.
  def formatted_value(value)
    return value if value.is_a?(Float) || value.is_a?(Integer)

    value.respond_to?(:keys) ? value.to_json : value&.to_s
  end

  ##
  # When converting existing records into events, set `occurred_at` to the time the record was created, if the
  # record's `created_at` value is passed to Event#trigger in the `data` param.
  # @param [Hash{Symbol => Object}] data Any data included with the event, which, in the case of converting
  # existing records into events, will include attributes from the existing record being converted.
  def occurred_at(data)
    time = if data[:created_at].present?
             data[:created_at]
           else
             Time.now.utc
           end
    time.iso8601(6)
  end

  ##
  # Personally identifiable information (PII) should be anonymised before the data is sent to BigQuery
  def anonymise(identifier)
    StringAnonymiser.new(identifier).to_s if identifier.present?
  end
end
