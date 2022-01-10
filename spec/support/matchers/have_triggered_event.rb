require "rspec/expectations"

RSpec::Matchers.define :have_triggered_event do |event_type|
  supports_block_expectations

  match do |proc|
    raise ArgumentError, "have_triggered_event only supports block expectations" unless proc.respond_to?(:call)

    all_data = (expected_base_data || {}).merge(type: event_type)
    all_data[:data] = array_including(expected_data.map { |key, value| { key: key.to_s, value: } }) if expected_data

    expect(proc).to have_enqueued_job(SendEventToDataWarehouseJob).with(Event::TABLE_NAME, hash_including(all_data))
  end

  chain :with_request_data do
    # An event with request data will include (at least) the request method in the base data. We don't check _all_ fields
    # so we don't need to keep amending this matcher when the set of base data in `RequestEvent` changes.
    # Note: This chain should not be used in conjunction with the more lower-level `with_base_data`, and cannot be used
    #       outside of tests that have request data accessible (e.g. model or job specs)
    @expected_base_data = { request_method: request.method }
  end

  chain :with_base_data, :expected_base_data
  chain :and_base_data, :expected_base_data

  chain :with_data, :expected_data
  chain :and_data, :expected_data
end
