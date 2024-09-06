require "rails_helper"

RSpec.describe WithdrawDraftApplicationsForExpiredVacanciesJob, type: :job do
  before do
    vacancy.save!
    described_class.perform_now
  end

  context "with an expired vacancy" do
    let(:vacancy) do
      build(:vacancy, :expired,
            job_applications: [
              build(:job_application, :status_draft),
              build(:job_application, :status_submitted),
            ])
    end

    it "marks draft application as withdrawn" do
      expect(JobApplication.all.map(&:status)).to match_array(%w[submitted withdrawn])
    end

    it "sets withdrawn_at" do
      expect(JobApplication.all.map(&:withdrawn_at).filter_map { |datetime| datetime.to_date if datetime.present? }).to match_array([Date.today])
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
