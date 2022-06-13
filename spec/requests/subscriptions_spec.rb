require "rails_helper"

RSpec.describe "Subscriptions" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }

  describe "GET #new" do
    context "with search criteria pre-populated" do
      it "sets subscription_autopopulated in the session so we can track it with subscription events" do
        get new_subscription_path(search_criteria: { key: "value" })

        expect(session[:subscription_autopopulated]).to eq(true)
      end
    end

    context "with search criteria not pre-populated" do
      it "sets subscription_autopopulated in the session so we can track it with subscription events" do
        get new_subscription_path

        expect(session[:subscription_autopopulated]).to eq(false)
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

  describe "POST #create", recaptcha: true do
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
      # Required to set the session
      get new_subscription_path
    end

    it "calls Jobseekers::SubscriptionMailer" do
      expect(Jobseekers::SubscriptionMailer).to receive_message_chain(:confirmation, :deliver_later)
      subject
    end

    it "creates a subscription" do
      expect { subject }.to change { Subscription.count }.by(1)
      expect(created_subscription.email).to eq("foo@example.net")
      expect(created_subscription.search_criteria.symbolize_keys).to eq({ keyword: "english", location: "London" })
    end

    it "triggers a `job_alert_subscription_created` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_created).and_data(
        autopopulated: "false",
        email_identifier: anonymised_form_of("foo@example.net"),
        frequency: "daily",
        subscription_identifier: anything,
        recaptcha_score: 0.9,
        search_criteria: /^{.*}$/,
      )
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
        expect { subject }.to change { Subscription.count }.by(0)
      end
    end
  end

  describe "PATCH #update" do
    subject { put subscription_path(subscription.token), params: { jobseekers_subscription_form: params } }

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
      expect { subject }.not_to(change { Subscription.count })
      expect(subscription.reload.email).to eq("jimi@hendrix.com")
      expect(subscription.reload.search_criteria.symbolize_keys).to eq({ keyword: "english", location: "London" })
    end

    it "triggers a `job_alert_subscription_updated` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_updated).and_data(
        autopopulated: nil,
        email_identifier: anonymised_form_of("jimi@hendrix.com"),
        frequency: "weekly",
        subscription_identifier: anonymised_form_of(subscription.id),
        search_criteria: /^{.*}$/,
      )
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
    let!(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily) }

    subject { delete subscription_path(subscription.token) }

    it "triggers a `job_alert_subscription_unsubscribed` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_unsubscribed).and_data(
        autopopulated: nil,
        email_identifier: anonymised_form_of("bob@dylan.com"),
        frequency: "daily",
        subscription_identifier: anonymised_form_of(subscription.id),
        search_criteria: /^{.*}$/,
      )
    end
  end
end
