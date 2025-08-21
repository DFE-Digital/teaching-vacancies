require "rails_helper"

RSpec.describe HardDeleteRetentionPolicyJob do
  let(:over_5_years_ago) { 5.years.ago - 1.day }

  before do
    create(:job_application, :status_draft)
    create(:job_application, :status_submitted, submitted_at: over_5_years_ago)
    create(:job_application, :status_shortlisted, submitted_at: over_5_years_ago)
    create(:job_application, :status_interviewing_with_pre_checks, submitted_at: over_5_years_ago)
    create(:job_application, :status_interviewing_with_pre_checks)
    create(:job_application, :status_submitted)

    described_class.perform_now
  end

  it "performs hard delete" do
    expect(SelfDisclosure.count).to eq(1)
    expect(SelfDisclosureRequest.count).to eq(1)
    expect(ReferenceRequest.count).to eq(1)
    expect(JobReference.count).to eq(1)
    expect(JobApplication.count).to eq(3)
  end
end
