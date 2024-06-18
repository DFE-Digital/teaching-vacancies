require "rails_helper"

RSpec.describe Publishers::JobApplicationReceivedNotifier do
  let(:vacancy) { create(:vacancy, :published, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  describe "#timestamp" do
    context "when the notification is delivered today" do
      before do
        described_class
          .with(vacancy: job_application.vacancy, job_application: job_application)
          .deliver(vacancy.publisher)
      end

      it "returns the correct timestamp" do
        expect(Noticed::Notification.last.timestamp).to match(/Today at/)
      end
    end

    context "when the notification was delivered yesterday" do
      before do
        described_class
          .with(vacancy: job_application.vacancy, job_application: job_application)
          .deliver(vacancy.publisher)
        allow_any_instance_of(Noticed::Notification).to receive(:created_at) { Time.current - 1.day }
      end

      it "returns the correct timestamp" do
        expect(Noticed::Notification.last.timestamp).to match(/Yesterday at/)
      end
    end

    context "when the notification was delivered before yesterday" do
      before do
        described_class
          .with(vacancy: job_application.vacancy, job_application: job_application)
          .deliver(vacancy.publisher)
        allow_any_instance_of(Noticed::Notification).to receive(:created_at) { DateTime.new(2000, 0o1, 0o1, 14, 30) }
      end

      it "returns the correct timestamp" do
        expect(Noticed::Notification.last.timestamp).to eq("1 January at 2:30pm")
      end
    end
  end
end
