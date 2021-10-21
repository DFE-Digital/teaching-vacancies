require "rails_helper"

RSpec.describe Jobseeker do
  it { is_expected.to have_many(:saved_jobs) }
  it { is_expected.to have_many(:job_applications) }

  describe "update_subscription_emails" do
    let(:jobseeker) { create(:jobseeker) }
    let!(:subscription) { create(:subscription, email: jobseeker.email) }
    let(:new_email_address) { "new_email@example.com" }

    it "updates the email address of every subscription associated with their previous email address" do
      expect {
        jobseeker.update(email: new_email_address)
        jobseeker.confirm
      }.to change { subscription.reload.email }.to(new_email_address)
    end
  end
end
