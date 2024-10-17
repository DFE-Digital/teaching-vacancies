require "rails_helper"

RSpec.describe DeleteOldNonDraftJobApplicationsJob, type: :job do
  let(:jobseeker) { create(:jobseeker) }
  let(:over_5_years_ago) { 5.years.ago - 1.day }

  before do
    job_applications.each(&:save!)
    described_class.perform_now
  end

  context "with some but not all old applications" do
    let(:job_applications) do
      [
        create(:job_application, :status_submitted, jobseeker: jobseeker, submitted_at: over_5_years_ago),
        create(:job_application, :status_submitted, jobseeker: jobseeker, submitted_at: over_5_years_ago),
        create(:job_application, :status_draft, jobseeker: jobseeker, submitted_at: over_5_years_ago),
        create(:job_application, :status_submitted, jobseeker: jobseeker),
      ]
    end

    it "deletes all old submitted applications" do
      expect(JobApplication.count).to eq(2)
    end
  end

  context "with all old job applications" do
    let(:job_applications) do
      [
        create(:job_application, :status_submitted, jobseeker: jobseeker, submitted_at: over_5_years_ago),
        create(:job_application, :status_submitted, jobseeker: jobseeker, submitted_at: over_5_years_ago - 1.day),
      ]
    end

    it "retains the last application for a user" do
      expect(JobApplication.all).to eq([job_applications.first])
    end
  end
end
