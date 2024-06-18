require "rails_helper"

RSpec.describe SendJobApplicationDataExpiryNotifierJob do
  let(:notification) { instance_double(Publishers::JobApplicationDataExpiryNotifier) }
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let!(:vacancy) { create(:vacancy, expires_at: 351.days.ago, publisher: publisher, organisations: [organisation]) }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false) }

  context "when the vacancy has no job applications" do
    it "does not send notifications" do
      expect(Publishers::JobApplicationDataExpiryNotifier).not_to receive(:with).with(vacancy: vacancy, publisher: publisher)
      described_class.perform_now
    end
  end

  context "when the vacancy has job applications" do
    let!(:job_application) { create(:job_application, vacancy: vacancy) }

    context "when the vacancy expired 351 days ago" do
      it "sends notifications" do
        expect(Publishers::JobApplicationDataExpiryNotifier).to receive(:with).with(vacancy: vacancy, publisher: publisher).and_return(notification)
        expect(notification).to receive(:deliver).with(publisher)
        described_class.perform_now
      end
    end

    context "when the vacancy did not expire 351 days ago" do
      let!(:vacancy) { create(:vacancy, expires_at: 1.day.ago, publisher: publisher, organisations: [organisation]) }

      it "does not send notifications" do
        expect(Publishers::JobApplicationDataExpiryNotifier).not_to receive(:with).with(vacancy: vacancy, publisher: publisher)
        described_class.perform_now
      end
    end
  end
end
