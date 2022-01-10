require "rails_helper"

RSpec.describe "Job alert unsubscription feedback" do
  let(:jobseeker) { create(:jobseeker) }
  let(:subscription) { create(:subscription, email: jobseeker.email) }

  describe "POST #create" do
    context "when form is valid" do
      before { allow_any_instance_of(Jobseekers::UnsubscribeFeedbackForm).to receive(:valid?) { true } }

      context "when jobseeker is signed in" do
        before { login_as(jobseeker, scope: :jobseeker) }

        let(:params) { { jobseekers_unsubscribe_feedback_form: { comment: "Stop emailing me!" } } }

        it "redirects to the job alerts dashboard after feedback is submitted" do
          expect { post(subscription_unsubscribe_feedbacks_path(subscription), params:) }.to change { jobseeker.feedbacks.count }.by(1)

          expect(response).to redirect_to(jobseekers_subscriptions_path)
        end
      end
    end
  end
end
