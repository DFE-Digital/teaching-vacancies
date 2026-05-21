require "rails_helper"

RSpec.describe "discard_invalid_subscriptions" do
  before do
    Subscription.destroy_all
    create(:subscription)
    build(:subscription, email: "invalid").save!(validate: false)
  end

  # rubocop:disable RSpec/NamedSubject
  it "marks the invalid subscription as discarded", :retry do
    expect {
      subject.execute
    }.to change { Subscription.kept.count }.by(-1)
  end
  # rubocop:enable RSpec/NamedSubject
end
