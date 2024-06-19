require "rails_helper"

RSpec.describe Publishers::JobApplicationDataExpiryNotifier do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }
  let(:vacancy) { create(:vacancy, publisher: publisher, organisations: [organisation]) }

  describe "#message" do
    subject { Noticed::Notification.last.message }

    let(:data_expiration_date) { (vacancy.expires_at + 1.year).to_date }
    let(:vacancy_applications_link) { "/organisation/jobs/#{vacancy.id}/job_applications" }

    before do
      described_class
        .with(vacancy: vacancy, publisher: publisher)
        .deliver(publisher)
    end

    it "returns the correct message" do
      expect(subject).to include(vacancy.job_title)
                     .and include(format_date(data_expiration_date))
                     .and include(vacancy_applications_link)
    end
  end
end
