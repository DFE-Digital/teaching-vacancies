require "rails_helper"

RSpec.describe SubscriptionsController, recaptcha: true do
  describe "#create" do
    let(:params) do
      {
        jobseekers_subscription_form: {
          email: "foo@example.net",
          frequency: "daily",
          keyword: "english",
        }.symbolize_keys,
      }
    end
    subject { post :create, params: params }
    let(:created_subscription) { Subscription.last }

    before do
      session[:subscription_origin] = "/some/where"
    end

    context "when verifying recaptcha" do
      let(:recaptcha_score) { 0.9 }
      let(:job_alert_params) do
        {
          email: "foo@example.net",
          frequency: "daily",
          search_criteria: { keyword: "english" },
        }
      end

      let(:subscription) { instance_double(Subscription).as_null_object }
      let(:form) { instance_double(Jobseekers::SubscriptionForm) }
      let(:subscription_form_valid?) { true }

      before do
        allow(Subscription).to receive(:new).and_return(subscription)
        allow(subscription).to receive(:id).and_return("abc123")
        allow(subscription).to receive(:class).and_return(Subscription)
        allow(Jobseekers::SubscriptionForm).to receive(:new).and_return(form)
        allow(form).to receive(:job_alert_params).and_return(job_alert_params)
        allow(form).to receive(:invalid?).and_return(!subscription_form_valid?)
        allow(form).to receive(:class).and_return(Jobseekers::SubscriptionForm)
        allow(controller).to receive(:recaptcha_reply).and_return({ "score" => recaptcha_score })
        allow(controller).to receive(:verify_recaptcha).and_return(verify_recaptcha)
      end

      context "when verify_recaptcha is true" do
        let(:verify_recaptcha) { true }

        it "verifies the recaptcha" do
          expect(controller).to receive(:verify_recaptcha)
          subject
        end

        it "sends the action when it verifies the recaptcha" do
          expect(controller).to receive(:verify_recaptcha)
                                  .with(model: nil,
                                        action: "subscriptions",
                                        minimum_score: SubscriptionsController::SUSPICIOUS_RECAPTCHA_THRESHOLD)
          subject
        end

        it "sets the recaptcha score on the Subscription record" do
          expect(subscription).to receive(:update).with(recaptcha_score: recaptcha_score)
          subject
        end
      end

      context "when verify_recaptcha is false" do
        let(:verify_recaptcha) { false }

        before do
          allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
        end

        it "sets the recaptcha score on the Subscription record" do
          expect(subscription).to receive(:update).with(recaptcha_score: recaptcha_score)
          subject
        end

        it "sends the recaptcha error to Sentry" do
          expect(Sentry).to receive(:capture_message).with("Invalid recaptcha", level: :warning)
          subject
        end
      end
    end
  end
end
