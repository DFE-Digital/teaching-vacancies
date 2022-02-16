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
                                        minimum_score: ApplicationController::SUSPICIOUS_RECAPTCHA_THRESHOLD)
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

        context "and subscription form is valid" do
          it "redirects to invalid_recaptcha_path" do
            subject
            expect(response).to redirect_to(invalid_recaptcha_path(form_name: "Subscription"))
          end

          it "does not save the Subscription record" do
            expect(subscription).not_to receive(:save)
            subject
          end
        end

        context "and subscription is not valid" do
          let(:subscription_form_valid?) { false }

          it "does not save the Subscription record" do
            expect(subscription).not_to receive(:save)
            subject
          end

          it "renders :new" do
            subject
            expect(response).to render_template(:new)
          end
        end
      end
    end
  end

  describe "#update" do
    let(:subscription) { instance_double(Subscription).as_null_object }
    let(:subscription_presenter) { instance_double(SubscriptionPresenter).as_null_object }

    before do
      allow(Subscription).to receive(:find_and_verify_by_token).with("123").and_return(subscription)
      allow(subscription).to receive(:id).and_return("123")
      allow(SubscriptionPresenter).to receive(:new).with(subscription).and_return(subscription_presenter)
    end

    context "when updating via subscription params" do
      let(:params) do
        {
          id: "123",
          subscription: {
            frequency: "daily",
          },
        }
      end
      subject { patch :update, params: params }

      it "updates the subscription frequency" do
        expect(subscription).to receive(:update).with(frequency: params.dig(:subscription, :frequency))
        subject
      end
    end

    context "when updating via jobseeker subscription form" do
      let(:form) { instance_double(Jobseekers::SubscriptionForm) }
      let(:params) do
        {
          id: "123",
          jobseekers_subscription_form: {
            email: "foo@example.net",
            frequency: "daily",
            keyword: "english",
          },
        }
      end

      let(:job_alert_params) do
        {
          email: "foo@example.net",
          frequency: "daily",
          search_criteria: { keyword: "english" },
        }
      end

      subject { patch :update, params: params }

      before do
        allow(Jobseekers::SubscriptionForm).to receive(:new).and_return(form)
        allow(form).to receive(:job_alert_params).and_return(job_alert_params)
        allow(form).to receive(:valid?).and_return(true)
      end

      it "updates the subscription" do
        expect(subscription).to receive(:update).with(form.job_alert_params)
        subject
      end
    end
  end
end
