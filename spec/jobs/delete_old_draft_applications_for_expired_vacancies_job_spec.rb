require "rails_helper"

RSpec.describe DeleteOldDraftApplicationsForExpiredVacanciesJob do
  context "with an expired vacancy" do
    before do
      vacancy = create(:vacancy, :expired)
      travel_to(6.years.ago) do
        create(:job_application, :status_draft, vacancy:)
      end
      create(:job_application, :status_draft, vacancy:)
      create(:job_application, :status_submitted, vacancy:)
      described_class.perform_now
    end

    it "deletes the old draft application" do
      expect(JobApplication.all.map(&:status)).to match_array(%w[submitted draft])
    end
  end

  context "with an unexpired vacancy" do
    before do
      vacancy = create(:vacancy)
      create(:job_application, :status_draft, vacancy:, updated_at: 6.years.ago)
      described_class.perform_now
    end

    it "does not touch draft applications" do
      expect(JobApplication.all.map(&:status)).to eq(%w[draft])
    end
  end
end
