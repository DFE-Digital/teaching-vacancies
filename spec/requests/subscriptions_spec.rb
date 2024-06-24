require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "Subscriptions" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }

  describe "GET #new" do
    context "with search criteria pre-populated" do
      it "sets subscription_autopopulated in the session so we can track it with subscription events" do
        get new_subscription_path(search_criteria: { key: "value" })

        expect(session[:subscription_autopopulated]).to be(true)
      end
    end

    context "with search criteria not pre-populated" do
      it "sets subscription_autopopulated in the session so we can track it with subscription events" do
        get new_subscription_path

        expect(session[:subscription_autopopulated]).to be(false)
      end
    end

    context "when containing campaign parameters" do
      let(:params) { { "email_contact" => "user@example.com", email_postcode: "SW12JP" } }

      it "renders the template for the campaign users with pre-filled values" do
        get(new_subscription_path, params:)

        expect(response).to render_template("subscriptions/campaign/new")
        expect(response.body).to include("user@example.com")
                             .and include("SW12JP")
      end
    end

    context "when hit via the nqt job alerts url" do
      before { get "/sign-up-for-NQT-job-alerts" }

      it "redirects to the ect job alerts url" do
        expect(response).to redirect_to(ect_job_alerts_path)
      end
    end

    context "when hit via the ECT job alerts url" do
      let(:params) { { "ect_job_alert" => true, "search_criteria" => { "job_roles" => ["ect_suitable"] } } }

      before { get ect_job_alerts_path }

      it "includes the correct parameters" do
        expect(request.parameters).to include(params)
      end
    end
  end

  describe "POST #create", :recaptcha do
    subject { post subscriptions_path, params: params }

    let(:params) do
      {
        jobseekers_subscription_form: {
          email: "foo@example.net",
          frequency: "daily",
          location: "London",
          keyword: "english",
        }.symbolize_keys,
      }
    end
    let(:created_subscription) { Subscription.last }

    before do
      create(:location_polygon, name: "london")

      # Required to set the session
      get new_subscription_path
    end

    it "calls Jobseekers::SubscriptionMailer" do
      expect(Jobseekers::SubscriptionMailer).to receive_message_chain(:confirmation, :deliver_later)
      subject
    end

    it "creates a subscription" do
      expect { subject }.to change(Subscription, :count).by(1)
      expect(created_subscription.email).to eq("foo@example.net")
      expect(created_subscription.search_criteria.symbolize_keys).to eq({ keyword: "english", location: "London", radius: "0" })
    end

    it "triggers a `job_alert_subscription_created` event" do
      subject

      expect(:job_alert_subscription_created).to have_been_enqueued_as_analytics_events
    end

    context "with unsafe params" do
      let(:params) do
        {
          jobseekers_subscription_form: {
            email: "<script>foo@example.net</script>",
            frequency: "daily",
            location: "London",
            search_criteria: "<body onload=alert('test1')>Text</body>",
          },
        }
      end

      it "does not create a subscription" do
        expect { subject }.not_to(change(Subscription, :count))
      end
    end
  end

  describe "PATCH #update" do
    subject { put subscription_path(subscription.token), params: { jobseekers_subscription_form: params } }

    before { create(:location_polygon, name: "london") }

    let!(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily) }

    let(:params) do
      {
        email: "jimi@hendrix.com",
        frequency: "weekly",
        location: "London",
        keyword: "english",
      }
    end

    it "updates the subscription" do
      expect { subject }.not_to(change(Subscription, :count))
      expect(subscription.reload.email).to eq("jimi@hendrix.com")
      expect(subscription.reload.search_criteria.symbolize_keys).to eq({ keyword: "english", location: "London", radius: "0" })
    end

    it "triggers a `job_alert_subscription_updated` event" do
      subject

      expect(:job_alert_subscription_updated).to have_been_enqueued_as_analytics_events
    end

    context "with unsafe params" do
      let(:params) do
        {
          email: "<script>foo@example.net</script>",
          frequency: "daily",
          search_criteria: "<body onload=alert('test1')>Text</body>",
        }
      end

      it "does not update a subscription" do
        expect(subscription.reload.email).to eq("bob@dylan.com")
      end
    end
  end

  describe "DELETE #destroy" do
    subject { delete subscription_path(subscription.token) }

    let!(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily) }

    it "triggers a `job_alert_subscription_unsubscribed` event" do
      subject

      expect(:job_alert_subscription_unsubscribed).to have_been_enqueued_as_analytics_events
    end
  end
end
