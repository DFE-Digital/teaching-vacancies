require "rails_helper"

RSpec.describe Publishers::JobApplicationReceivedNotifier do
  let(:vacancy) { create(:vacancy, :published, organisations: [build(:school)]) }
  let(:publisher) { vacancy.publisher }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  describe "#timestamp" do
    context "when the notification is delivered today" do
      before do
        described_class
          .with(vacancy: job_application.vacancy, job_application: job_application)
          .deliver(publisher)
      end

      it "returns the correct timestamp" do
        expect(publisher.notifications.last.timestamp).to match(/Today at/)
      end
    end

    context "when the notification was delivered yesterday" do
      before do
        travel_to 1.day.ago do
          described_class
            .with(vacancy: job_application.vacancy, job_application: job_application)
            .deliver(publisher)
        end
        publisher.notifications.last.update(created_at: Time.current - 1.day)
      end

      it "returns the correct timestamp" do
        expect(publisher.notifications.last.timestamp).to match(/Yesterday at/)
      end
    end

    context "when the notification was delivered before yesterday" do
      before do
        travel_to DateTime.new(2000, 0o1, 0o1, 14, 30) do
          described_class
            .with(vacancy: job_application.vacancy, job_application: job_application)
            .deliver(publisher)
        end
        publisher.notifications.last.update(created_at: DateTime.new(2000, 0o1, 0o1, 14, 30))
      end

      it "returns the correct timestamp" do
        expect(publisher.notifications.last.timestamp).to match("1 January at 2:30pm")
      end
    end
  end
end
