require "rails_helper"

RSpec.describe SoftDeleteRetentionPolicyJob do
  let(:over_6_months_ago) { 6.months.ago - 1.day }

  before do
    create(:job_application, :status_draft)
    create(:job_application, :status_submitted, submitted_at: over_6_months_ago)
    create(:job_application, :status_shortlisted, submitted_at: over_6_months_ago)
    create(:job_application, :status_interviewing_with_pre_checks, submitted_at: over_6_months_ago)
    create(:job_application, :status_interviewing_with_pre_checks)
    create(:job_application, :status_submitted)

    described_class.perform_now
  end

  it "performs soft delete" do
    expect(SelfDisclosure.kept.count).to eq(1)
    expect(SelfDisclosureRequest.kept.count).to eq(1)
    expect(ReferenceRequest.kept.count).to eq(1)
    expect(JobReference.kept.count).to eq(1)
    expect(JobApplication.kept.count).to eq(3)
  end
end
