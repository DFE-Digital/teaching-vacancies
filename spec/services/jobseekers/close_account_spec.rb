require "rails_helper"

RSpec.describe Jobseekers::CloseAccount do
  subject { described_class.new(jobseeker, close_account_feedback_form_params) }

  let(:jobseeker) { create(:jobseeker) }
  let(:close_account_feedback_form_params) { {} }
  let!(:subscription) { create(:subscription, email: jobseeker.email, active: true) }
  let!(:job_application) { create(:job_application, :reviewed, jobseeker: jobseeker) }

  describe "#call" do
    before { subject.call }

    it "sets jobseeker account_closed_on to current date" do
      expect(jobseeker.account_closed_on).to eq Date.current
    end

    context "when close_account_feedback_form_params are present" do
      let(:close_account_feedback_form_params) { { close_account_reason: "not_getting_any_value" } }

      it "sets feedback_form_params on the created feedback" do
        expect(jobseeker.feedbacks.first.close_account_reason).to eq "not_getting_any_value"
      end

      it "sets feedback_type on the created feedback" do
        expect(jobseeker.feedbacks.first.feedback_type).to eq "close_account"
      end
    end

    context "when close_account_feedback_form_params are not present" do
      let(:close_account_feedback_form_params) { {} }

      it "does not create feedback" do
        expect(jobseeker.feedbacks).to be_none
      end
    end

    it "sends an email to jobseeker" do
      expect { subject.call }
        .to have_enqueued_email(Jobseekers::AccountMailer, :account_closed)
        .with(jobseeker)
    end

    it "marks subscriptions as inactive" do
      expect(subscription.reload.active).to be false
    end

    it "withdraws job applications" do
      expect(job_application.reload).to be_withdrawn
    end

    it "marks job applications as withdrawn_by_closing_account" do
      expect(job_application.reload.withdrawn_by_closing_account).to be true
    end
  end
end
