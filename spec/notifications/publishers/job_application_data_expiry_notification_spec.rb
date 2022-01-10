require "rails_helper"

RSpec.describe Publishers::JobApplicationDataExpiryNotification do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }
  let(:vacancy) { create(:vacancy, publisher:, organisations: [organisation]) }

  describe "#message" do
    subject { Notification.last.to_notification.message }

    let(:data_expiration_date) { (vacancy.expires_at + 1.year).to_date }
    let(:vacancy_applications_link) { "/organisation/jobs/#{vacancy.id}/job_applications" }

    before do
      described_class
        .with(vacancy:, publisher:)
        .deliver(publisher)
    end

    it "returns the correct message" do
      expect(subject).to include(vacancy.job_title)
                     .and include(format_date(data_expiration_date))
                     .and include(vacancy_applications_link)
    end
  end

  describe "#timestamp" do
    subject { Notification.last.to_notification.timestamp }

    context "when the notification is delivered today" do
      before do
        described_class
          .with(vacancy:, publisher:)
          .deliver(publisher)
      end

      it "returns the correct timestamp" do
        expect(subject).to include("Today at")
      end
    end

    context "when the notification was delivered yesterday" do
      before do
        travel_to 1.day.ago do
          described_class
            .with(vacancy:, publisher:)
            .deliver(publisher)
        end
      end

      it "returns the correct timestamp" do
        expect(subject).to include("Yesterday at")
      end
    end

    context "when the notification was delivered before yesterday" do
      before do
        travel_to DateTime.new(2000, 0o1, 0o1, 14, 30) do
          described_class
            .with(vacancy:, publisher:)
            .deliver(publisher)
        end
      end

      it "returns the correct timestamp" do
        expect(subject).to eq("1 January at 2:30pm")
      end
    end
  end
end
