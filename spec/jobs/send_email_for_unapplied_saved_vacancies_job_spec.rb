require "rails_helper"

RSpec.describe SendEmailForUnappliedSavedVacanciesJob, type: :job do
  let(:jobseeker) { create(:jobseeker, :with_profile) }
  let(:vacancy) { create(:vacancy, expires_at: expires_at) }

  before do
    create(:saved_job, vacancy: vacancy, jobseeker: jobseeker)
  end

  context "when vacancy has 10 days left" do
    let(:expires_at) { Date.today + 10.days + 2.hours }

    context "when an application hasnt been made" do
      before do
        expect(Jobseekers::VacancyMailer).to receive(:unapplied_saved_vacancy).with(vacancy, jobseeker).at_least(:once).and_call_original
      end

      it "sends an email" do
        perform_enqueued_jobs { described_class.perform_later }
      end
    end

    context "when an application has been made" do
      before do
        create(:job_application, jobseeker: jobseeker, vacancy: vacancy)
        expect(Jobseekers::VacancyMailer).not_to receive(:unapplied_saved_vacancy)
      end

      it "doesnt send an email" do
        perform_enqueued_jobs { described_class.perform_later }
      end
    end
  end

  context "when vacancy has 9 days left" do
    let(:expires_at) { Date.today + 9.days + 2.hours }
    before do
      expect(Jobseekers::VacancyMailer).not_to receive(:unapplied_saved_vacancy)
    end

    it "doesnt send an email" do
      perform_enqueued_jobs { described_class.perform_later }
    end
  end
end
