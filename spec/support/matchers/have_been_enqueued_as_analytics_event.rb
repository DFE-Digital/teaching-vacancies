# frozen_string_literal: true

# Allows to assert against the enqueued DFE Analytics events.
# The matcher can be used in the following way:
# - First option. Assert that the event type was enqueued:
#     expect(:event_type).to have_been_enqueued_as_analytics_event
# - Second option. Assert that the event type was enqueued with specific data:
#     expect(:event_type).to have_been_enqueued_as_analytics_event(with_data: { key: "value" })
# - Third option. Assert that the event type was enqueued with specific data keys (without asserting against the values):
#     expect(:event_type).to have_been_enqueued_as_analytics_event(with_data: [:key1, :key2])
#
# Copied and extended from dfe-analytics matcher:
# https://github.com/DFE-Digital/dfe-analytics/blob/main/lib/dfe/analytics/rspec/matchers/have_been_enqueued_as_analytics_events.rb
RSpec::Matchers.define :have_been_enqueued_as_analytics_event do |args|
  match do |event_type|
    data = args&.fetch(:with_data, {})
    if data.present?
      jobs = jobs_to_event_types_with_data(queue_adapter.enqueued_jobs)
      expect(jobs).to include(
        hash_including(
          event_type: event_type.to_s,
          data: data.is_a?(Array) ? hash_including(*data) : hash_including(data),
        ),
      )
    else
      expect(enqueued_event_types).to include(event_type.to_s)
    end
  end

  failure_message do |event_type|
    if enqueued_event_types.blank?
      "expected #{event_type} to have been sent as an analytics event type, but no analytics events were sent"
    elsif enqueued_event_types.include?(event_type.to_s)
      wanted_data = args&.fetch(:with_data, {})
      if wanted_data.any?
        jobs = jobs_to_event_types_with_data(queue_adapter.enqueued_jobs)
        if wanted_data.is_a?(Array)
          data_keys = jobs.filter_map { |job| job[:data].keys if job[:event_type] == event_type.to_s }.first
          "expected #{event_type} to have been sent with data keys: #{wanted_data}, but was was sent with: #{data_keys}"
        else
          data = jobs.filter_map { |job| job[:data] if job[:event_type] == event_type.to_s }.first
          "expected #{event_type} to have been sent with data: #{wanted_data}, but was was sent with: #{data}}"
        end
      end
    else
      "expected #{event_type} to have been sent as an analytics event type, but found event types: #{enqueued_event_types.uniq}"
    end
  end

  def queue_adapter
    ActiveJob::Base.queue_adapter
  end

  def jobs_to_event_types(jobs)
    jobs.map { |job|
      next unless job["job_class"] == "DfE::Analytics::SendEvents"

      job[:args].first.map do |e|
        e.fetch("event_type")
      end
    }.flatten
  end

  def jobs_to_event_types_with_data(jobs)
    jobs.map { |job|
      next unless job["job_class"] == "DfE::Analytics::SendEvents"

      job[:args].first.map do |e|
        {
          event_type: e.fetch("event_type"),
          data: parse_data(e.fetch("data", {})),
        }
      end
    }.flatten.compact
  end

  def parse_data(data)
    return {} if data.none?

    data.each_with_object({}) do |kv, h|
      h[kv.fetch("key").to_sym] = kv.fetch("value")&.first
    end
  end

  def enqueued_event_types
    @enqueued_event_types ||= jobs_to_event_types(queue_adapter.enqueued_jobs)
  end
end
