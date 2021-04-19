require "rspec/expectations"

RSpec::Matchers.define :have_delivered_notification do |notification_type|
  supports_block_expectations

  match do |proc|
    raise ArgumentError, "have_delivered_notification only supports block expectations" unless proc.respond_to?(:call)

    expected_attributes = {
      type: notification_type,
      params: (hash_including(expected_params) if expected_params),
      recipient: expected_recipient,
    }.compact

    expect(proc).to change { Notification.count }.by(1)
    expect(Notification.last).to have_attributes(expected_attributes)
  end

  chain :with_params, :expected_params
  chain :and_params, :expected_params

  chain :with_recipient, :expected_recipient
  chain :and_recipient, :expected_recipient
end
