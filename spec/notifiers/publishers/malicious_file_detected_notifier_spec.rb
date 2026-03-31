# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publishers::MaliciousFileDetectedNotifier do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }

  describe "#message" do
    before do
      described_class.with(filename: "malicious.pdf", publisher: publisher).deliver(publisher)
    end

    it "returns the correct message including the filename" do
      expect(publisher.notifications.last.message).to include("malicious.pdf")
      expect(publisher.notifications.last.message).to include("automatically removed")
    end
  end

  describe "#timestamp" do
    before do
      described_class.with(filename: "malicious.pdf", publisher: publisher).deliver(publisher)
    end

    it "returns a timestamp" do
      expect(publisher.notifications.last.timestamp).to match(/Today at/)
    end
  end
end
