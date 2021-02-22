require "rails_helper"

RSpec.describe "Subscriptions", type: :request do
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }

  describe "GET #new" do
    context "with valid origin" do
      let(:origin) { "/jobs/#{vacancy.id}/#{vacancy.slug}" }

      it "sets the origin in the session so we can track it with subscription events" do
        get new_subscription_path(origin: origin)

        expect(session[:subscription_origin]).to eq(origin)
      end

      it "triggers a `vacancy_create_job_alert_clicked` event" do
        expect { get new_subscription_path(origin: origin) }
          .to have_triggered_event(:vacancy_create_job_alert_clicked)
          .and_data(vacancy_id: vacancy.id)
      end
    end

    context "with invalid origin" do
      let(:origin) { "https://www.evil.com" }

      it "ignores origin param unless it's a path on our app" do
        get new_subscription_path(origin: origin)

        expect(session[:subscription_origin]).not_to be_present
      end
    end
  end

  describe "POST #create", recaptcha: true do
    subject { post subscriptions_path, params: params }

    let(:params) do
      {
        jobseekers_subscription_form: {
          email: "foo@email.com",
          frequency: "daily",
          keyword: "english",
        }.symbolize_keys,
      }
    end
    let(:created_subscription) { Subscription.last }

    before do
      # Required to set the session
      get new_subscription_path(origin: "/some/where")
    end

    it "creates a subscription" do
      expect { subject }.to change { Subscription.count }.by(1)
      expect(created_subscription.email).to eq("foo@email.com")
      expect(created_subscription.search_criteria.symbolize_keys).to eq({ keyword: "english" })
    end

    it "triggers a `job_alert_subscription_created` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_created).and_data(
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
  end

  describe "PUT #update" do
    subject { put subscription_path(subscription.token), params: { jobseekers_subscription_form: params } }

    let!(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily) }

    let(:params) do
      {
        email: "jimi@hendrix.com",
        frequency: "weekly",
        keyword: "english",
      }
    end

    it "updates the subscription" do
      expect { subject }.not_to(change { Subscription.count })
      expect(subscription.reload.email).to eq("jimi@hendrix.com")
      expect(subscription.reload.search_criteria.symbolize_keys).to eq({ keyword: "english" })
    end

    it "triggers a `job_alert_subscription_updated` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_updated).and_data(
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

  describe "DELETE #destroy" do
    let!(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily) }

    subject { delete subscription_path(subscription.token) }

    it "triggers a `job_alert_subscription_unsubscribed` event" do
      expect { subject }.to have_triggered_event(:job_alert_subscription_unsubscribed).and_data(
        email_identifier: anonymised_form_of("bob@dylan.com"),
        frequency: "daily",
        subscription_identifier: anonymised_form_of(subscription.id),
        search_criteria: /^{.*}$/,
      )
    end
  end
end
