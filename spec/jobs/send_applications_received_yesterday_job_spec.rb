require "rails_helper"

RSpec.describe SendApplicationsReceivedYesterdayJob do
  subject(:job) { described_class.perform_later }

  let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
  let(:school) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [school], contact_email: "test@contoso.com") }
  let(:other_vacancy) { create(:vacancy, organisations: [school], contact_email: "admin@contoso.com") }

  context "when there are applications which were submitted yesterday" do
    before do
      create(:job_application, :status_submitted, vacancy: vacancy, submitted_at: 1.day.ago)
      create(:job_application, :status_submitted, vacancy: vacancy, submitted_at: 1.day.ago)
      create(:job_application, :status_submitted, vacancy: other_vacancy, submitted_at: 1.day.ago)
    end

    it "sends one email per contact_email regardless of number of applications" do
      # Should receive exactly 2 email calls, one for each contact_email
      expect(Publishers::JobApplicationMailer)
        .to receive(:applications_received)
        .with(contact_email: "test@contoso.com")
        .and_return(message_delivery)

      expect(Publishers::JobApplicationMailer)
        .to receive(:applications_received)
        .with(contact_email: "admin@contoso.com")
        .and_return(message_delivery)

      expect(message_delivery).to receive(:deliver_later).twice

      perform_enqueued_jobs { job }
    end
  end

  context "when there are submitted applications that were not submitted yesterday" do
    before do
      create(:job_application, :status_submitted, vacancy: vacancy, submitted_at: Time.current)
    end

    it "does not send emails for applications submitted today" do
      expect(Publishers::JobApplicationMailer).not_to receive(:applications_received)

      perform_enqueued_jobs { job }
    end
  end

  context "when there are no submitted applications" do
    before do
      create(:job_application, :status_draft, vacancy: vacancy)
    end

    it "does not send emails for draft applications from yesterday" do
      expect(Publishers::JobApplicationMailer).not_to receive(:applications_received)

      perform_enqueued_jobs { job }
    end
  end

  context "when there are vacancies missing contact_emails" do
    let(:vacancy_without_contact_email) { create(:vacancy, organisations: [school], contact_email: nil) }

    before do
      create(:job_application, :status_submitted, vacancy: vacancy_without_contact_email, submitted_at: 1.day.ago)
    end

    it "does not attempt to send email" do
      expect(Publishers::JobApplicationMailer).not_to receive(:applications_received)

      perform_enqueued_jobs { job }
    end
  end
end
