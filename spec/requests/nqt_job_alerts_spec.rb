require "rails_helper"

RSpec.describe "NqtJobAlerts", type: :request, recaptcha: true do
  let(:keywords) { "something" }
  let(:location) { "some place" }
  let(:email) { "test@gmail.com" }

  let(:form_inputs) { { keywords: keywords, location: location, email: email } }

  describe "#create" do
    let(:params) { { jobseekers_nqt_job_alerts_form: form_inputs } }
    let(:search_criteria) { { keyword: "nqt #{keywords}", location: location, radius: 10 } }
    let(:subscription) { Subscription.last }
    subject { post new_nqt_job_alert_path, params: params }

    it "calls Jobseekers::SubscriptionMailer" do
      expect(Jobseekers::SubscriptionMailer).to receive_message_chain(:confirmation, :deliver_later)
      subject
    end

    it "creates a subscription" do
      expect { subject }.to change { Subscription.count }.by(1)
      expect(subscription.email).to eq(email)
      expect(subscription.search_criteria.symbolize_keys).to eq(search_criteria)
    end

    it "triggers a `job_alert_subscription_created` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_created).and_data(
        email_identifier: anonymised_form_of("test@gmail.com"),
        frequency: "daily",
        subscription_identifier: anything,
        recaptcha_score: 0.9,
        search_criteria: /^{.*}$/,
      )
    end
  end
end
