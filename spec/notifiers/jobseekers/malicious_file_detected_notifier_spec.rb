# frozen_string_literal: true

require "rails_helper"

RSpec.describe Jobseekers::MaliciousFileDetectedNotifier do
  let(:jobseeker) { create(:jobseeker) }

  describe "#message" do
    before do
      described_class.with(filename: "malicious.pdf", jobseeker: jobseeker).deliver(jobseeker)
    end

    it "returns the correct message including the filename" do
      expect(jobseeker.notifications.last.message).to include("malicious.pdf")
      expect(jobseeker.notifications.last.message).to include("removed because it contained malware")
    end
  end

  describe "#timestamp" do
    before do
      described_class.with(filename: "malicious.pdf", jobseeker: jobseeker).deliver(jobseeker)
    end

    it "returns a timestamp" do
      expect(jobseeker.notifications.last.timestamp).to match(/Today at/)
    end
  end
end
