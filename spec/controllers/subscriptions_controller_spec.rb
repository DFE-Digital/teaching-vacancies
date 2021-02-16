require "rails_helper"

RSpec.describe SubscriptionsController, type: :controller, recaptcha: true do
  describe "#new" do
    it "sets the origin in the session so we can track it with subscription events" do
      get :new, params: { origin: "/foo/bar?baz=bat" }

      expect(session[:subscription_origin]).to eq("/foo/bar?baz=bat")
    end

    it "ignores origin param unless it's a path on our app" do
      get :new, params: { origin: "https://www.evil.com" }

      expect(session[:subscription_origin]).not_to be_present
    end
  end

  describe "#create" do
    let(:params) do
      {
        jobseekers_subscription_form: {
          email: "foo@email.com",
          frequency: "daily",
          keyword: "english",
        }.symbolize_keys,
      }
    end
    let(:subject) { post :create, params: params }
    let(:created_subscription) { Subscription.last }

    before do
      session[:subscription_origin] = "/some/where"
    end

    it "creates a subscription" do
      expect { subject }.to change { Subscription.count }.by(1)
      expect(created_subscription.email).to eq("foo@email.com")
      expect(created_subscription.search_criteria.symbolize_keys).to eq({ keyword: "english" })
    end

    it "triggers a `job_alert_subscription_created` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_created).with_request_data.and_data(
        email_identifier: anonymised_form_of("foo@email.com"),
        frequency: "daily",
        subscription_identifier: anything,
        recaptcha_score: 0.9,
        search_criteria: /^{.*}$/,
        origin: "/some/where",
      )
    end

    context "with unsafe params" do
      let(:params) do
        {
          jobseekers_subscription_form: {
            email: "<script>foo@email.com</script>",
            frequency: "daily",
            search_criteria: "<body onload=alert('test1')>Text</body>",
          },
        }
      end

      it "does not create a subscription" do
        expect { subject }.to change { Subscription.count }.by(0)
      end
    end

    context "when verifying recaptcha" do
      let(:recaptcha_score) { 0.9 }
      let(:job_alert_params) do
        {
          email: "foo@email.com",
          frequency: "daily",
          search_criteria: { keyword: "english" },
        }
      end

      let(:subscription) { instance_double(Subscription).as_null_object }
      let(:subscription_form) { instance_double(Jobseekers::SubscriptionForm) }
      let(:subscription_form_valid?) { true }

      before do
        allow(Subscription).to receive(:new).and_return(subscription)
        allow(subscription).to receive(:id).and_return("abc123")
        allow(subscription).to receive(:class).and_return(Subscription)
        allow(Jobseekers::SubscriptionForm).to receive(:new).and_return(subscription_form)
        allow(subscription_form).to receive(:job_alert_params).and_return(job_alert_params)
        allow(subscription_form).to receive(:invalid?).and_return(!subscription_form_valid?)
        allow(subscription_form).to receive(:class).and_return(Jobseekers::SubscriptionForm)
        allow(controller).to receive(:recaptcha_reply).and_return({ "score" => recaptcha_score })
        allow(controller).to receive(:verify_recaptcha).and_return(verify_recaptcha)
      end

      context "when verify_recaptcha is true" do
        let(:verify_recaptcha) { true }

        it "verifies the recaptcha" do
          expect(controller).to receive(:verify_recaptcha)
          subject
        end

        it "sends the Subscription instance and action (both required) when it verifies the recaptcha" do
          expect(controller).to receive(:verify_recaptcha)
                                  .with(model: subscription,
                                        action: "subscriptions",
                                        minimum_score: ApplicationController::SUSPICIOUS_RECAPTCHA_THRESHOLD)
          subject
        end

        it "sets the recaptcha score on the Subscription record" do
          expect(subscription).to receive(:recaptcha_score=).with(recaptcha_score)
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
    let!(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily) }

    let(:params) do
      {
        email: "jimi@hendrix.com",
        frequency: "weekly",
        keyword: "english",
      }
    end
    let(:subject) { put :update, params: { id: subscription.token, jobseekers_subscription_form: params } }

    it "updates the subscription" do
      expect { subject }.not_to(change { Subscription.count })
      expect(subscription.reload.email).to eq("jimi@hendrix.com")
      expect(subscription.reload.search_criteria.symbolize_keys).to eq({ keyword: "english" })
    end

    it "triggers a `job_alert_subscription_updated` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_updated).with_request_data.and_data(
        email_identifier: anonymised_form_of("jimi@hendrix.com"),
        frequency: "weekly",
        subscription_identifier: anonymised_form_of(subscription.id),
        search_criteria: /^{.*}$/,
      )
    end

    context "with unsafe params" do
      let(:params) do
        {
          email: "<script>foo@email.com</script>",
          frequency: "daily",
          search_criteria: "<body onload=alert('test1')>Text</body>",
        }
      end

      it "does not update a subscription" do
        expect(subscription.reload.email).to eq("bob@dylan.com")
      end
    end
  end

  describe "#destroy" do
    let!(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily) }

    let(:subject) { delete :destroy, params: { id: subscription.token } }

    it "triggers a `job_alert_subscription_unsubscribed` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_unsubscribed).with_request_data.and_data(
        email_identifier: anonymised_form_of("bob@dylan.com"),
        frequency: "daily",
        subscription_identifier: anonymised_form_of(subscription.id),
        search_criteria: /^{.*}$/,
      )
    end
  end
end
