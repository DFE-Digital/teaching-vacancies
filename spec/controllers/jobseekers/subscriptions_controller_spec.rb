require "rails_helper"

RSpec.describe SubscriptionsController, :recaptcha do
  describe "#create" do
    subject { post :create, params: params }

    let(:params) do
      {
        jobseekers_subscription_form: {
          email: "foo@example.net",
          frequency: "daily",
          keyword: "english",
        }.symbolize_keys,
      }
    end
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
      let(:errors) { instance_double(ActiveModel::Errors, add: nil) }
      let(:form) { instance_double(Jobseekers::SubscriptionForm, errors: errors) }
      let(:subscription_form_valid?) { true }

      before do
        allow(Subscription).to receive(:new).and_return(subscription)
        allow(subscription).to receive_messages(id: "abc123", class: Subscription)
        allow(Jobseekers::SubscriptionForm).to receive(:new).and_return(form)
        allow(form).to receive_messages(job_alert_params: job_alert_params, invalid?: !subscription_form_valid?, class: Jobseekers::SubscriptionForm)
        allow(controller).to receive_messages(recaptcha_reply: { "score" => recaptcha_score }, verify_recaptcha: verify_recaptcha)
      end

      context "when verify_recaptcha V3 is true" do
        let(:verify_recaptcha) { true }

        it "verifies the recaptcha once with v3" do
          subject
          expect(controller).to have_received(:verify_recaptcha)
                            .with(hash_including(secret_key: ENV.fetch("RECAPTCHA_V3_SECRET_KEY", ""))).once
          expect(controller).not_to have_received(:verify_recaptcha).with(no_args)
        end

        it "renders the subscription confirmation page" do
          expect(subject).to render_template("confirm")
        end

        context "when the subscriber is a signed in jobseeker" do
          before do
            sign_in create(:jobseeker)
          end

          it "redirects to the subscriptions page for the jobseeker" do
            expect(subject).to redirect_to(jobseekers_subscriptions_path)
          end
        end
      end

      context "when verify_recaptcha V3 is false" do
        let(:verify_recaptcha) { false }

        before do
          allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
        end

        it "verifies the recaptcha once with v3 and once with v2" do
          subject
          expect(controller).to have_received(:verify_recaptcha)
                            .with(hash_including(secret_key: ENV.fetch("RECAPTCHA_V3_SECRET_KEY", ""))).once
          expect(controller).to have_received(:verify_recaptcha).with(no_args).once
        end

        it "renders the 'new' page" do
          expect(subject).to render_template("new")
        end
      end
    end
  end
end
