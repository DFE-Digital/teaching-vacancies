require "rails_helper"

RSpec.describe Jobseekers::ReactivateAccount do
  subject { described_class.new(jobseeker) }

  let(:jobseeker) { create(:jobseeker, closed_account: true) }
  let!(:subscription) { create(:subscription, email: jobseeker.email, active: false) }
  let!(:subscription_previously_unsubscribed) { create(:subscription, email: jobseeker.email, active: false, unsubscribed_at: 1.day.ago) }
  let!(:job_application) { create(:job_application, :withdrawn, jobseeker: jobseeker, withdrawn_by_closing_account: true, status_before_withdrawn: "reviewed") }

  describe "#call" do
    before { subject.call }

    it "marks jobseeker account as not closed" do
      expect(jobseeker.closed_account).to be false
    end

    it "marks subscriptions as active" do
      expect(subscription.reload.active).to be true
    end

    it "doesn't mark subscriptions previously unsubscribed as active" do
      expect(subscription_previously_unsubscribed.reload.active).to be false
    end

    it "resets marked withdrawn job applications' status" do
      expect(job_application.reload).to be_reviewed
    end

    it "resets withdrawn_by_closing_account on job applications" do
      expect(job_application.reload.withdrawn_by_closing_account).to be false
    end

    it "resets status_before_withdrawn on job applications" do
      expect(job_application.reload.status_before_withdrawn).to be_nil
    end
  end
end
