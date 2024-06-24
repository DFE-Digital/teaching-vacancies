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

  describe "#needs_email_confirmation?" do
    subject(:jobseeker) { build_stubbed(:jobseeker) }

    context "when the user is confirmed" do
      before { jobseeker.confirmed_at = Time.current }

      context "when the user does not have a new unconfirmed email address" do
        before { jobseeker.unconfirmed_email = nil }

        it { is_expected.not_to be_needs_email_confirmation }
      end

      context "when the user has a new unconfirmed email address" do
        before { jobseeker.unconfirmed_email = "foobar@example.com" }

        it { is_expected.to be_needs_email_confirmation }
      end
    end

    context "when the user is not confirmed" do
      before { jobseeker.confirmed_at = nil }

      context "when the user does not have a new unconfirmed email address" do
        before { jobseeker.unconfirmed_email = nil }

        it { is_expected.to be_needs_email_confirmation }
      end

      context "when the user has a new unconfirmed email address" do
        before { jobseeker.unconfirmed_email = "foobar@example.com" }

        it { is_expected.to be_needs_email_confirmation }
      end
    end
  end
end
