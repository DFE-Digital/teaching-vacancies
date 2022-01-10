require "rails_helper"

RSpec.describe Publishers::JobApplicationReceivedNotification do
  let(:vacancy) { create(:vacancy, :published, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy:) }

  describe "#timestamp" do
    subject { Notification.last.to_notification.timestamp }

    context "when the notification is delivered today" do
      before do
        described_class
          .with(vacancy: job_application.vacancy, job_application:)
          .deliver(vacancy.publisher)
      end

      it "returns the correct timestamp" do
        expect(subject).to match(/Today at/)
      end
    end

    context "when the notification was delivered yesterday" do
      before do
        travel_to 1.day.ago do
          described_class
            .with(vacancy: job_application.vacancy, job_application:)
            .deliver(vacancy.publisher)
        end
      end

      it "returns the correct timestamp" do
        expect(subject).to match(/Yesterday at/)
      end
    end

    context "when the notification was delivered before yesterday" do
      before do
        travel_to DateTime.new(2000, 0o1, 0o1, 14, 30) do
          described_class
            .with(vacancy: job_application.vacancy, job_application:)
            .deliver(vacancy.publisher)
        end
      end

      it "returns the correct timestamp" do
        expect(subject).to eq("1 January at 2:30pm")
      end
    end
  end
end
