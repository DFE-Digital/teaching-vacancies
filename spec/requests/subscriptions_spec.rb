require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "Subscriptions" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }

  describe "GET #new" do
    context "with search criteria pre-populated" do
      it "sets subscription_autopopulated in the session so we can track it with subscription events" do
        get new_subscription_path(search_criteria: { keyword: "value" })

        expect(session[:subscription_autopopulated]).to eq(true)
      end
    end

    context "with search criteria not pre-populated" do
      it "sets subscription_autopopulated in the session so we can track it with subscription events" do
        get new_subscription_path

        expect(session[:subscription_autopopulated]).to eq(false)
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
      let(:params) { { "ect_job_alert" => true, "search_criteria" => { "teaching_job_roles" => ["ect_suitable"] } } }

      before { get ect_job_alerts_path }

      it "includes the correct parameters" do
        expect(request.parameters).to include(params)
      end
    end
  end

  describe "POST #create", recaptcha: true do
    subject { post subscriptions_path, params: params }
    let(:email_address) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }

    let(:params) do
      {
        jobseekers_subscription_form: {
          email: email_address,
          frequency: "daily",
          location: "London",
          radius: "10",
          keyword: "english",
        }.symbolize_keys,
      }
    end
    let(:created_subscription) { Subscription.last }

    before do
      allow(SetSubscriptionLocationDataJob).to receive(:perform_later)
      create(:location_polygon, name: "london")

      # Required to set the session
      get new_subscription_path
    end

    it "calls Jobseekers::SubscriptionMailer" do
      expect(Jobseekers::SubscriptionMailer).to receive_message_chain(:confirmation, :deliver_later)
      subject
    end

    it "creates a subscription" do
      expect { subject }.to change { Subscription.count }.by(1)
      expect(created_subscription.email).to eq(email_address)
      expect(created_subscription.search_criteria.symbolize_keys).to eq({ keyword: "english", location: "London", radius: "10" })
    end

    it "fills the location data for the subscription" do
      expect(SetSubscriptionLocationDataJob).to receive(:perform_later).and_call_original
      perform_enqueued_jobs do
        subject
      end
      expect(created_subscription.reload.uk_area).not_to be_nil
      expect(created_subscription.radius_in_metres).to eq(16_090)
    end

    it "triggers a `job_alert_subscription_created` event", :dfe_analytics do
      subject

      expect(:job_alert_subscription_created).to have_been_enqueued_as_analytics_event( # rubocop:disable RSpec/ExpectActual
        with_data: %i[autopopulated frequency recaptcha_score search_criteria subscription_identifier],
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

    # rubocop:disable RSpec/AnyInstance
    describe "recaptcha verification", recaptcha: true do
      let(:recaptcha_score) { 0.9 }
      let(:recaptcha_reply) { instance_double(Recaptcha::Reply, score: recaptcha_score) }

      before do
        allow_any_instance_of(SubscriptionsController).to receive_messages(recaptcha_reply:, verify_recaptcha:)
      end

      context "when verify_recaptcha V3 is true" do
        let(:verify_recaptcha) { true }

        it "verifies the recaptcha once with v3" do
          expect_any_instance_of(SubscriptionsController)
            .to receive(:verify_recaptcha)
            .with(hash_including(secret_key: ENV.fetch("RECAPTCHA_V3_SECRET_KEY", ""))) # V3
            .once
          expect_any_instance_of(SubscriptionsController).not_to receive(:verify_recaptcha).with(no_args) # V2
          subject
        end

        it "records the recaptcha score on the subscription" do
          subject
          expect(created_subscription.recaptcha_score).to eq(recaptcha_score)
        end

        context "when the recaptcha reply as yet not been fetched" do
          let(:recaptcha_reply) { nil }

          it "records a nil recaptcha score" do
            subject
            expect(created_subscription.recaptcha_score).to be_nil
          end
        end

        it "renders the subscription confirmation page" do
          subject
          expect(response).to render_template("subscriptions/confirm")
        end

        context "when the subscriber is a signed in jobseeker" do
          before do
            sign_in create(:jobseeker)
          end

          it "redirects to the subscriptions page for the jobseeker" do
            subject
            expect(response).to redirect_to(jobseekers_subscriptions_path)
          end
        end
      end

      context "when verify_recaptcha V3 is false" do
        let(:verify_recaptcha) { false }

        it "verifies the recaptcha once with v3 and once with v2" do
          expect_any_instance_of(SubscriptionsController)
            .to receive(:verify_recaptcha)
            .with(hash_including(secret_key: ENV.fetch("RECAPTCHA_V3_SECRET_KEY", ""))).once # V3
          expect_any_instance_of(SubscriptionsController)
            .to receive(:verify_recaptcha).with(no_args).once # V2
          subject
        end

        it "renders the 'new' page" do
          expect(response).to render_template("subscriptions/new")
        end
      end
    end
    # rubocop:enable RSpec/AnyInstance
  end

  describe "PATCH #update" do
    subject { put subscription_path(subscription.token), params: { jobseekers_subscription_form: params } }

    before do
      create(:location_polygon, name: "london")
      allow(SetSubscriptionLocationDataJob).to receive(:perform_later)
    end

    let(:old_email_address) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
    let!(:subscription) do
      create(:subscription, :with_some_criteria, :with_area_location, email: old_email_address, frequency: :daily)
    end

    let(:email_address) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
    let(:params) do
      {
        email: email_address,
        frequency: "weekly",
        location: subscription.search_criteria["location"],
        keyword: "maths",
        radius: subscription.search_criteria["radius"],
      }
    end

    it "updates the subscription" do
      original_search_criteria = subscription.search_criteria
      expect { subject }.not_to(change { Subscription.count })
      expect(subscription.reload.email).to eq(email_address)
      expect(subscription.reload.search_criteria.symbolize_keys)
        .to eq({ keyword: "maths", location: original_search_criteria["location"], radius: original_search_criteria["radius"] })
    end

    it "triggers a `job_alert_subscription_updated` event", :dfe_analytics do
      subject

      expect(:job_alert_subscription_updated).to have_been_enqueued_as_analytics_event( # rubocop:disable RSpec/ExpectActual
        with_data: %i[autopopulated frequency recaptcha_score search_criteria subscription_identifier],
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
        subject
        expect(subscription.reload.email).to eq(old_email_address)
      end
    end

    context "when only updating the frequency" do
      subject { put subscription_path(subscription.token), params: { subscription: { frequency: "weekly" } } }

      it "updates the frequency" do
        expect {
          subject
          subscription.reload
        }.to change { subscription.frequency }.from("daily").to("weekly")
      end

      it "does not update the search criteria" do
        expect {
          subject
          subscription.reload
        }.not_to(change { subscription.search_criteria })
      end
    end

    context "when the subscription non location search criteria is changed" do
      let(:params) { super().merge(keyword: "maths") }

      it "changes the subscription search criteria without filling location data" do
        expect(SetSubscriptionLocationDataJob).not_to receive(:perform_later)
        expect {
          subject
          subscription.reload
        }.to change { subscription.search_criteria["keyword"] }.to("maths")
         .and(not_change { subscription.search_criteria["location"] })
         .and(not_change { subscription.search_criteria["radius"] })
         .and(not_change { subscription.uk_area })
         .and(not_change { subscription.uk_geopoint })
         .and(not_change { subscription.radius_in_metres })
      end
    end

    context "when the subscription radius is changed" do
      let(:params) { super().merge(radius: "15") }

      it "changes the subscription search criteria and fills location data", :perform_enqueued do
        expect(SetSubscriptionLocationDataJob).to receive(:perform_later).and_call_original
        expect {
          subject
          subscription.reload
        }.to change { subscription.search_criteria.symbolize_keys }.to({ keyword: "maths", location: "London", radius: "15" })
          .and change { subscription.radius_in_metres }.to(24_135)
          .and change { subscription.uk_area }
          .and(not_change { subscription.uk_geopoint })
      end
    end

    context "when the location is changed to a location without a polygon" do
      let(:params) { super().merge(location: "EC12JP") }

      it "changes the subscription search criteria and fills location data with a geopoint", :perform_enqueued do
        expect(SetSubscriptionLocationDataJob).to receive(:perform_later).and_call_original
        expect {
          subject
          subscription.reload
        }.to change { subscription.search_criteria.symbolize_keys }.to({ keyword: "maths", location: "EC12JP", radius: "10" })
        .and change { subscription.uk_geopoint&.as_text }.from(nil).to("POINT (412245.368031182 142199.44022881394)") # Default stub coordinates for tests.
        .and change { subscription.uk_area }.to(nil)
      end
    end

    context "when the location is changed from a location with geopoint to a location with a polygon" do
      let!(:subscription) do
        create(:subscription, :with_some_criteria, :with_geopoint_location, frequency: :daily)
      end
      let(:params) { super().merge(location: "London") }

      it "changes the subscription search criteria and fills location data with a geopoint", :perform_enqueued do
        expect(SetSubscriptionLocationDataJob).to receive(:perform_later).and_call_original
        expect {
          subject
          subscription.reload
        }.to change { subscription.search_criteria.symbolize_keys }.to({ keyword: "maths", location: "London", radius: "10" })
        .and change { subscription.uk_geopoint }.to(nil)
        .and change { subscription.uk_area }.from(nil).to(kind_of(RGeo::Cartesian::PolygonImpl))
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:subscription) { create(:subscription, frequency: :daily) }

    subject { delete subscription_path(subscription.token) }

    it "triggers a `job_alert_subscription_unsubscribed` event", :dfe_analytics do
      subject

      expect(:job_alert_subscription_unsubscribed).to have_been_enqueued_as_analytics_event( # rubocop:disable RSpec/ExpectActual
        with_data: %i[autopopulated frequency recaptcha_score search_criteria subscription_identifier],
      )
    end

    it "includes utm_campaign in analytics event when present", :dfe_analytics do
      delete subscription_path(subscription.token, utm_campaign: "subscription_governance")

      expect(:job_alert_subscription_unsubscribed).to have_been_enqueued_as_analytics_event( # rubocop:disable RSpec/ExpectActual
        with_data: %i[autopopulated frequency recaptcha_score search_criteria subscription_identifier utm_campaign],
      )
    end
  end

  describe "GET #keep" do
    let!(:subscription) do
      create(:subscription, frequency: :daily).tap do |s|
        s.update_column(:deletion_warning_email_sent_at, 2.weeks.ago)
        s.update_column(:updated_at, 13.months.ago)
      end
    end

    subject { get keep_subscription_path(subscription.token) }

    it "clears deletion_warning_email_sent_at and updates updated_at to prevent another warning" do
      freeze_time do
        expect {
          subject
          subscription.reload
        }.to change { subscription.deletion_warning_email_sent_at }.from(kind_of(ActiveSupport::TimeWithZone)).to(nil)
          .and change { subscription.updated_at }.to(be_within(1.minute).of(Time.current))
      end
    end

    it "redirects with a success message and triggers event", :dfe_analytics do
      subject
      expect(response).to redirect_to(root_path)
      expect(flash[:success]).to be_present
      expect(:job_alert_subscription_kept).to have_been_enqueued_as_analytics_event( # rubocop:disable RSpec/ExpectActual
        with_data: %i[autopopulated frequency recaptcha_score search_criteria subscription_identifier],
      )
    end

    context "with an invalid token" do
      subject { get keep_subscription_path("invalid-token") }

      it "returns a 404 status" do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
