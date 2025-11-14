require "rails_helper"

RSpec.describe "discard_invalid_subscriptions" do
  include_context "with rake"

  before do
    create(:subscription)
    build(:subscription, email: "invalid").save!(validate: false)
  end

  # its(:prerequisites) { is_expected.to include("environment") }

  # rubocop:disable RSpec/NamedSubject
  it "marks the invalid subscription as discarded" do
    expect {
      subject.invoke
    }.to change { Subscription.kept.count }.by(-1)
  end
  # rubocop:enable RSpec/NamedSubject
end
