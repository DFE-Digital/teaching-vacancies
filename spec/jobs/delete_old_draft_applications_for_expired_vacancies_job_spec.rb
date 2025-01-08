require "rails_helper"

RSpec.describe DeleteOldDraftApplicationsForExpiredVacanciesJob do
  before do
    vacancy.save!
    JobApplication.draft.first.update!(updated_at: 6.years.ago)
    described_class.perform_now
  end

  context "with an expired vacancy" do
    let(:vacancy) do
      build(:vacancy, :expired,
            job_applications: [
              build(:job_application, :status_draft),
              build(:job_application, :status_draft),
              build(:job_application, :status_submitted),
            ])
    end

    it "deletes the old draft application" do
      expect(JobApplication.all.map(&:status)).to match_array(%w[submitted draft])
    end
  end

  context "with an unexpired vacancy" do
    let(:vacancy) do
      build(:vacancy, job_applications: [build(:job_application, :status_draft)])
    end

    it "does not touch draft applications" do
      expect(JobApplication.all.map(&:status)).to eq(%w[draft])
    end
  end
end
