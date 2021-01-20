require "rails_helper"

RSpec.describe SubscriptionsController, type: :controller do
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
        subscription_form: {
          email: "foo@email.com",
          frequency: "daily",
          keyword: "english",
        }.symbolize_keys,
      }
    end
    let(:subject) { post :create, params: params }
    let(:subscription) { Subscription.last }

    before do
      session[:subscription_origin] = "/some/where"
    end

    it "creates a subscription" do
      expect { subject }.to change { Subscription.count }.by(1)
      expect(subscription.email).to eq("foo@email.com")
      expect(subscription.search_criteria).to eq({ keyword: "english" }.to_json)
    end

    it "triggers a `job_alert_subscription_created` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_created).with_request_data.and_data(
        email_identifier: anonymised_form_of("foo@email.com"),
        frequency: "daily",
        subscription_identifier: anything,
        recaptcha_score: anything,
        search_criteria: /^{.*}$/,
        origin: "/some/where",
      )
    end

    context "with unsafe params" do
      let(:params) do
        {
          subscription_form: {
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
    let(:subject) { put :update, params: { id: subscription.token, subscription_form: params } }

    it "updates the subscription" do
      expect { subject }.not_to(change { Subscription.count })
      expect(subscription.reload.email).to eq("jimi@hendrix.com")
      expect(subscription.reload.search_criteria).to eq({ keyword: "english" }.to_json)
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

  describe "#unsubscribe" do
    let!(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily) }

    let(:subject) { get :unsubscribe, params: { id: subscription.token } }

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
