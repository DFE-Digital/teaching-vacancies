require "rails_helper"

RSpec.describe Jobseekers::ReactivateAccount do
  let(:jobseeker) { create(:jobseeker, account_closed_on: account_closed_on) }
  let(:account_closed_on) { Date.yesterday }
  let!(:subscription) { create(:subscription, email: jobseeker.email, active: false) }
  let!(:subscription_previously_unsubscribed) { create(:subscription, email: jobseeker.email, active: false, unsubscribed_at: 1.day.ago) }
  let!(:job_application) { create(:job_application, :withdrawn, jobseeker: jobseeker, withdrawn_by_closing_account: true) }

  describe ".reactivate(jobseeker)" do
    before do
      allow(jobseeker).to receive(:update).and_call_original
      allow(subscription).to receive(:update).and_call_original
      allow(subscription_previously_unsubscribed).to receive(:update).and_call_original

      described_class.reactivate(jobseeker)
    end

    it "sets jobseeker account_closed_on to nil" do
      expect(jobseeker.account_closed_on).to be_nil
    end

    it "marks subscriptions as active" do
      expect(subscription.reload.active).to eq(true)
    end

    it "doesn't mark subscriptions previously unsubscribed as active" do
      expect(subscription_previously_unsubscribed.reload.active).to eq(false)
    end

    context "if the jobseeker's account isn't closed" do
      let(:account_closed_on) { nil }

      it "does nothing" do
        expect(jobseeker).not_to have_received(:update)
        expect(subscription).not_to have_received(:update)
        expect(subscription_previously_unsubscribed).not_to have_received(:update)
      end
    end
  end
end
