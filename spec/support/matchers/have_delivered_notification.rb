require "rspec/expectations"

RSpec::Matchers.define :have_delivered_notification do |notification_type|
  supports_block_expectations

  match do |proc|
    raise ArgumentError, "have_delivered_notification only supports block expectations" unless proc.respond_to?(:call)

    expected_notification_attributes = {
      type: "#{notification_type}::Notification",
      params: (hash_including(expected_params) if expected_params),
      recipient: expected_recipient,
    }.compact

    expected_event_attributes = {
      type: notification_type,
      params: (hash_including(expected_params) if expected_params),
    }

    expect(proc).to change { Noticed::Notification.count }.by(1)

    notification = Noticed::Notification.last
    event = Noticed::Event.find(notification.event_id)

    expect(notification).to have_attributes(expected_notification_attributes)
    expect(event).to have_attributes(expected_event_attributes)
  end

  chain :with_params, :expected_params
  chain :and_params, :expected_params

  chain :with_recipient, :expected_recipient
  chain :and_recipient, :expected_recipient
end
