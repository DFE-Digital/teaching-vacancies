require "rails_helper"

RSpec.describe SendEmailForDraftJobApplicationsJob, type: :job do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, expires_at: Date.today + time_left + 2.hours) }
  let(:job_application) { JobApplication.last }

  before do
    create(:job_application, :status_draft, vacancy: vacancy, jobseeker: jobseeker)
  end

  context "when vacancy has 10 days left" do
    let(:time_left) { 10.days }

    before do
      expect(Jobseekers::VacancyMailer).to receive(:draft_application_only).with(job_application).at_least(:once).and_call_original
    end

    it "sends an email" do
      perform_enqueued_jobs { described_class.perform_later }
    end
  end

  context "when vacancy has 9 days left" do
    let(:time_left) { 9.days }
    before do
      expect(Jobseekers::VacancyMailer).not_to receive(:draft_application_only)
    end

    it "doesnt send an email" do
      perform_enqueued_jobs { described_class.perform_later }
    end
  end

  context "when vacancy has 11 days left" do
    let(:time_left) { 11.days }
    before do
      expect(Jobseekers::VacancyMailer).not_to receive(:draft_application_only)
    end

    it "doesnt send an email" do
      perform_enqueued_jobs { described_class.perform_later }
    end
  end
end
