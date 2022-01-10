require "rails_helper"

RSpec.describe SendJobApplicationDataExpiryNotificationJob do
  let(:notification) { instance_double(Publishers::JobApplicationDataExpiryNotification) }
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let!(:vacancy) { create(:vacancy, expires_at: 351.days.ago, publisher:, organisations: [organisation]) }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false) }

  context "when the vacancy has no job applications" do
    it "does not send notifications" do
      expect(Publishers::JobApplicationDataExpiryNotification).not_to receive(:with).with(vacancy:, publisher:)
      described_class.perform_now
    end
  end

  context "when the vacancy has job applications" do
    let!(:job_application) { create(:job_application, vacancy:) }

    context "when the vacancy expired 351 days ago" do
      it "sends notifications" do
        expect(Publishers::JobApplicationDataExpiryNotification).to receive(:with).with(vacancy:, publisher:).and_return(notification)
        expect(notification).to receive(:deliver).with(publisher)
        described_class.perform_now
      end
    end

    context "when the vacancy did not expire 351 days ago" do
      let!(:vacancy) { create(:vacancy, expires_at: 1.day.ago, publisher:, organisations: [organisation]) }

      it "does not send notifications" do
        expect(Publishers::JobApplicationDataExpiryNotification).not_to receive(:with).with(vacancy:, publisher:)
        described_class.perform_now
      end
    end
  end
end
