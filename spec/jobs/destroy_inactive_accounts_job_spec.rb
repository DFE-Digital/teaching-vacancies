require "rails_helper"

RSpec.describe DestroyInactiveAccountsJob do
  let!(:jobseeker) do
    create(:jobseeker, last_sign_in_at: last_sign_in_at,
                       job_applications: build_list(:job_application, 1,
                                                    create_details: true, create_self_disclosure: true, create_references: true))
  end
  let!(:subscription) { create(:subscription, email: jobseeker.email) }
  let!(:feedback) { create(:feedback, jobseeker:, email: jobseeker.email) }
  let!(:saved_job) { create(:saved_job, jobseeker:) }

  before do
    described_class.perform_now
  end

  context "with inactive jobseeker" do
    let(:last_sign_in_at) { 6.years.ago }

    it "destroys jobseeker account data" do
      expect(Jobseeker.count).to eq 0
      expect(Feedback.count).to eq 0
      expect(Subscription.count).to eq 0
      expect(JobApplication.count).to eq 0
      expect(SavedJob.count).to eq 0
    end
  end

  context "with active jobseeker" do
    let(:last_sign_in_at) { 6.years.ago + 1.day }

    it "does not destroy jobseeker account data" do
      expect(Jobseeker.count).to eq 1
      expect(Feedback.count).to eq 1
      expect(Subscription.count).to eq 1
      expect(JobApplication.count).to eq 1
      expect(SavedJob.count).to eq 1
    end
  end
end
