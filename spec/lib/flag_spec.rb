require "rails_helper"
require "flag"

RSpec.describe Flag do
  context "when the flag is a feature flag" do
    subject { described_class.new("email_alerts") }

    context "when the flag is set to true" do
      before { stub_const("FEATURE_EMAIL_ALERTS", "true") }

      it { expect(subject.enabled?).to eq(true) }
    end

    context "when the flag is set to false" do
      before { stub_const("FEATURE_EMAIL_ALERTS", "false") }

      it { expect(subject.enabled?).to eq(false) }
    end

    context "when the flag is not set" do
      before { stub_const("FEATURE_EMAIL_ALERTS", nil) }

      it { expect(subject.enabled?).to eq(false) }
    end
  end

  context "when the flag is NOT a feature flag" do
    subject { described_class.new("downtime_message", is_feature: false) }

    context "when the flag is set to true" do
      before { stub_const("DOWNTIME_MESSAGE", "true") }

      it { expect(subject.enabled?).to eq(true) }
    end

    context "when the flag is set to false" do
      before { stub_const("DOWNTIME_MESSAGE", "false") }

      it { expect(subject.enabled?).to eq(false) }
    end

    context "when the flag is not set" do
      before { stub_const("DOWNTIME_MESSAGE", nil) }

      it { expect(subject.enabled?).to eq(false) }
    end
  end
end
