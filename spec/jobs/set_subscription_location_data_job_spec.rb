require "rails_helper"

RSpec.describe SetSubscriptionLocationDataJob do
  let(:subscription) { instance_double(Subscription) }

  it "calls set_location_data! on the found subscription" do
    allow(Subscription).to receive(:find_by).with(id: 123).and_return(subscription)
    expect(subscription).to receive(:set_location_data!)
    described_class.perform_now(123)
  end

  it "does nothing if the subscription is not found" do
    allow(Subscription).to receive(:find_by).with(id: 456).and_return(nil)
    expect { described_class.perform_now(456) }.not_to raise_error
  end
end
