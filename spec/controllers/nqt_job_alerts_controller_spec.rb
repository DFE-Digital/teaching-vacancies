require "rails_helper"

RSpec.describe NqtJobAlertsController, type: :controller, recaptcha: true do
  let(:keywords) { "something" }
  let(:location) { "some place" }
  let(:email) { "test@gmail.com" }

  let(:form_inputs) { { keywords: keywords, location: location, email: email } }

  describe "#create" do
    let(:params) { { jobseekers_nqt_job_alerts_form: form_inputs } }
    let(:search_criteria) { { keyword: "nqt #{keywords}", location: location, radius: 10 } }
    let(:subscription) { Subscription.last }
    let(:subject) { post :create, params: params }

    it "calls SubscriptionMailer" do
      expect(SubscriptionMailer).to receive_message_chain(:confirmation, :deliver_later)
      subject
    end

    it "creates a subscription" do
      expect { subject }.to change { Subscription.count }.by(1)
      expect(subscription.email).to eq(email)
      expect(subscription.search_criteria.symbolize_keys).to eq(search_criteria)
    end

    it "triggers a `job_alert_subscription_created` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_created).with_request_data.and_data(
        email_identifier: anonymised_form_of("test@gmail.com"),
        frequency: "daily",
        subscription_identifier: anything,
        recaptcha_score: anything,
        search_criteria: /^{.*}$/,
      )
    end

    context "when parameters include syntax" do
      let(:keywords) { "<body onload=alert('test1')>Text</script>" }
      let(:expected_safe_values) { { keywords: "Text", location: location, email: email } }

      it "sanitizes form inputs" do
        subject
        expect(controller.send(:nqt_job_alerts_params)).to eq(
          ActionController::Parameters.new(expected_safe_values).permit(:keywords, :location, :email),
        )
      end
    end
  end
end
