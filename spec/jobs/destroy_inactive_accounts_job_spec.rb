require "rails_helper"

RSpec.describe DestroyInactiveAccountsJob do
  let!(:jobseeker) { create(:jobseeker, last_sign_in_at:) }
  let!(:subscription) { create(:subscription, email: jobseeker.email) }
  let!(:feedback) { create(:feedback, jobseeker_id: jobseeker.id) }
  let!(:job_application) { create(:job_application, jobseeker:) }
  let!(:saved_job) { create(:saved_job, jobseeker:) }

  before do
    allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false)

    described_class.perform_now
  end

  context "with inactive jobseeker for 5 years and 2 weeks" do
    let(:last_sign_in_at) { 5.years.ago - 2.weeks }

    it "destroys jobseeker account data" do
      expect(Jobseeker.count).to be 0
      expect(Feedback.count).to be 0
      expect(Subscription.count).to be 0
      expect(JobApplication.count).to be 0
      expect(SavedJob.count).to be 0
    end
  end

  context "with active jobseeker" do
    let(:last_sign_in_at) { 2.days.ago }

    it "does not destroy jobseeker account data" do
      expect(Jobseeker.count).to be 1
      expect(Feedback.count).to be 1
      expect(Subscription.count).to be 1
      expect(JobApplication.count).to be 1
      expect(SavedJob.count).to be 1
    end
  end
end
