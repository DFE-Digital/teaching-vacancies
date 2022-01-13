require "rails_helper"

RSpec.describe SendJobListingEndedEarlyNotificationJob do
  subject(:job) { described_class.perform_later(vacancy) }
  let(:mail) { double("Mail::Message", deliver_later: true) }
  let(:vacancy) { create(:vacancy, :published) }

  before do
    allow(Jobseekers::JobApplicationMailer).to receive(:job_listing_ended_early) { mail }
  end

  context "when a vacancy has applications in draft" do
    context "when the vacancy has draft job applications" do
      let(:jobseeker_one) { create(:jobseeker) }
      let(:jobseeker_two) { create(:jobseeker) }
      let!(:job_application_one) { create(:job_application, :status_draft, jobseeker: jobseeker_one, vacancy: vacancy) }
      let!(:job_application_two) { create(:job_application, :status_draft, jobseeker: jobseeker_two, vacancy: vacancy) }

      it "sends an email to each jobseeker with a draft application" do
        expect(Jobseekers::JobApplicationMailer).to receive(:job_listing_ended_early).with(job_application_one, vacancy)
        expect(Jobseekers::JobApplicationMailer).to receive(:job_listing_ended_early).with(job_application_two, vacancy)
        expect(mail).to receive(:deliver_later)
        perform_enqueued_jobs { job }
      end
    end

    context "when the vacancy has no draft applications" do
      it "does not send an email" do
        expect(Jobseekers::JobApplicationMailer).to_not receive(:job_listing_ended_early)
        perform_enqueued_jobs { job }
      end
    end
  end
end
