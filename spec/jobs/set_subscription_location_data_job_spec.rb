require "rails_helper"

RSpec.describe SetSubscriptionLocationDataJob do
  let(:subscription) { instance_double(Subscription) }

  it "calls set_location_data! on the found subscription" do
    expect(subscription).to receive(:set_location_data!)
    described_class.perform_now(subscription)
  end
end
