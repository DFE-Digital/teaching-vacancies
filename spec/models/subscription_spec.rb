require "rails_helper"

RSpec.describe Subscription do
  it { is_expected.to have_many(:alert_runs) }
  it { is_expected.to respond_to(:recaptcha_score) }

  describe "scopes" do
    before(:each) do
      create_list(:subscription, 3, frequency: :daily)
      create_list(:subscription, 5, frequency: :weekly)
      create(:subscription, :inactive, frequency: :daily)
    end

    describe "#daily" do
      it "retrieves all subscriptions with frequency set to :daily" do
        expect(Subscription.daily.count).to eq(4)
      end
    end

    describe "#weekly" do
      it "retrieves all subscriptions with frequency set to :daily" do
        expect(Subscription.weekly.count).to eq(5)
      end
    end
  end

  context "with a feedback" do
    let(:subscription) { create(:subscription) }

    before do
      create(:feedback, subscription: subscription)
    end

    it "doesn't destroy related feedbacks when destroyed" do
      expect { subscription.destroy! }.not_to change(Feedback, :count)
    end
  end

  context "token generation" do
    before do
      stub_const("SUBSCRIPTION_KEY_GENERATOR_SECRET", "foo")
      stub_const("SUBSCRIPTION_KEY_GENERATOR_SALT", "bar")
    end

    let(:subscription) { create(:subscription, frequency: :daily) }
    let(:token) { subscription.token }

    it "generates a token" do
      expect(token).to_not be_nil
    end

    describe "#find_and_verify_by_token" do
      let(:result) { Subscription.find_and_verify_by_token(token) }

      it "finds by token" do
        expect(result).to eq(subscription)
      end

      context "when token is old" do
        let(:token) { subscription.token }

        it "finds by token" do
          travel 3.days do
            expect(result).to eq(subscription)
          end
        end
      end

      context "when token is incorrect" do
        let(:token) { subscription.id }

        it "raises an error" do
          expect { result }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when token has extra data" do
        let(:token) do
          expires = Time.current + 2.days
          token_values = { id: subscription.id, expires: expires }
          Subscription.encryptor.encrypt_and_sign(token_values)
        end

        it "finds by token" do
          expect(result).to eq(subscription)
        end
      end
    end
  end

  describe "#create_alert_run" do
    let(:subscription) { create(:subscription, frequency: :daily) }

    it "creates a run" do
      subscription.create_alert_run

      expect(subscription.alert_runs.count).to eq(1)
      expect(subscription.alert_runs.first.run_on).to eq(Date.current)
    end

    context "if a run exists for today" do
      let!(:alert_run) { subscription.alert_runs.create(run_on: Date.current) }

      it "does not create another run" do
        subscription.create_alert_run

        expect(subscription.alert_runs.count).to eq(1)
        expect(subscription.alert_runs.first.id).to eq(alert_run.id)
      end
    end
  end

  describe "#vacancies_matching" do
    subject(:vacancies) { subscription.vacancies_matching(scope, limit:) }

    let(:subscription) { create(:subscription) }
    let(:limit) { nil }
    let(:scope) { PublishedVacancy.all }

    context "when multiple vacancies match the subscription criteria" do
      let!(:first_vacancy) { create(:vacancy, job_title: "Maths Teacher") }
      let!(:second_vacancy) { create(:vacancy, job_title: "Science Teacher") }

      before do
        subscription.search_criteria["keyword"] = "Teacher"
      end

      it "returns the ids for all matching vacancies" do
        expect(vacancies).to contain_exactly(first_vacancy.id, second_vacancy.id)
      end

      context "when a limit is specified" do
        let(:limit) { 1 }

        it "returns only up to the specified limit of vacancy ids" do
          expect(vacancies.size).to eq(1)
          expect(vacancies.first).to be_in([first_vacancy.id, second_vacancy.id])
        end
      end
    end

    context "when a single vacancy matches the subscription criteria" do
      let!(:matching_vacancy) { create(:vacancy, job_title: "Maths Teacher") }

      before do
        subscription.search_criteria["keyword"] = "Maths"
        create(:vacancy, job_title: "History assistant")
      end

      it "returns the id for the matching vacancy" do
        expect(vacancies).to contain_exactly(matching_vacancy.id)
      end
    end

    context "when no vacancies match the subscription criteria" do
      before do
        subscription.search_criteria["keyword"] = "Nonexistent Job Title"
      end

      it "returns an empty array" do
        expect(vacancies).to be_empty
      end
    end
  end

  describe "#set_location_data!" do
    RSpec.shared_examples "not_setting_location_data" do
      it "does not set area, geopoint, or radius_in_metres" do
        expect {
          subscription.set_location_data!
          subscription.reload
        }.to not_change(subscription, :geopoint).from(nil)
         .and not_change(subscription, :radius_in_metres).from(nil)
         .and not_change(subscription, :area).from(nil)
      end
    end

    context "with a search criteria location matching a polygon with valid area" do
      let(:subscription) { create(:subscription, search_criteria: { "location" => " London ", "radius" => 10 }) }

      before do
        create(:location_polygon, name: "london")
      end

      it "sets the area field and radius_in_metres" do
        expect {
          subscription.set_location_data!
          subscription.reload
        }.to change(subscription, :area).from(nil).to(kind_of(RGeo::Cartesian::PolygonImpl))
         .and change(subscription, :radius_in_metres).from(nil).to(16_090)
         .and not_change(subscription, :geopoint).from(nil)
      end

      context "when the polygon previously had location data from coordinates" do
        let(:subscription) do
          create(:subscription, :with_geopoint_location, search_criteria: { "location" => " London ", "radius" => 15 })
        end

        it "sets the area field and radius_in_metres while deleting the geopoint" do
          expect {
            subscription.set_location_data!
            subscription.reload
          }.to change(subscription, :area).from(nil).to(kind_of(RGeo::Cartesian::PolygonImpl))
           .and change { subscription.geopoint.class }.from(RGeo::Cartesian::PointImpl).to(NilClass)
           .and change(subscription, :radius_in_metres).from(16_090).to(24_135)
        end
      end
    end

    context "with a search criteria location not matching a polygon with valid area" do
      let(:subscription) { create(:subscription, search_criteria: { "location" => " London ", "radius" => 10 }) }
      let(:geocoding_response) { [51.5074, -0.1278] }
      let(:geocoding) { instance_double(Geocoding, coordinates: geocoding_response) }

      before do
        allow(Geocoding).to receive(:new).and_return(geocoding)
        allow(LocationPolygon).to receive(:find_valid_for_location).and_return(nil)
      end

      it "sets the geopoint field and radius_in_metres" do
        expect {
          subscription.set_location_data!
          subscription.reload
        }.to change(subscription, :geopoint).from(nil).to(kind_of(RGeo::Cartesian::PointImpl))
         .and change(subscription, :radius_in_metres).from(nil).to(16_090)
         .and not_change(subscription, :area).from(nil)
      end

      context "when Geocoding returns no match coordinates" do
        let(:geocoding_response) { Geocoding::COORDINATES_NO_MATCH }

        it "does not set the geopoint or radius_in_metres" do
          expect {
            subscription.set_location_data!
            subscription.reload
          }.to not_change(subscription, :geopoint).from(nil)
           .and not_change(subscription, :radius_in_metres).from(nil)
           .and not_change(subscription, :area).from(nil)
        end
      end

      context "when Geocoding doesn't return coordinates" do
        let(:geocoding_response) { nil }

        it "does not set the geopoint or radius_in_metres" do
          expect {
            subscription.set_location_data!
            subscription.reload
          }.to not_change(subscription, :geopoint).from(nil)
           .and not_change(subscription, :radius_in_metres).from(nil)
           .and not_change(subscription, :area).from(nil)
        end
      end

      context "when the polygon previously had location data from area" do
        let(:subscription) do
          create(:subscription, :with_area_location, search_criteria: { "location" => "EC12JP", "radius" => 15 })
        end

        it "sets the geopoint field and radius_in_metres while deleting the area" do
          expect {
            subscription.set_location_data!
            subscription.reload
          }.to change(subscription, :geopoint).from(nil).to(kind_of(RGeo::Cartesian::PointImpl))
           .and change(subscription, :radius_in_metres).from(16_090).to(24_135)
           .and change { subscription.area.class }.from(RGeo::Cartesian::PolygonImpl).to(NilClass)
        end
      end
    end

    context "with blank location" do
      let(:subscription) { create(:subscription, search_criteria: { "location" => "   ", "radius" => 10 }) }

      it_behaves_like "not_setting_location_data"
    end

    context "with empty location" do
      let(:subscription) { create(:subscription, search_criteria: { "location" => "", "radius" => 10 }) }

      it_behaves_like "not_setting_location_data"
    end

    context "with no location" do
      let(:subscription) { create(:subscription, search_criteria: { "radius" => 10 }) }

      it_behaves_like "not_setting_location_data"
    end
  end

  describe "#update_with_search_criteria" do
    subject(:update_with_search_criteria) { subscription.update_with_search_criteria(new_attributes) }

    let!(:subscription) do
      create(:subscription,
             search_criteria: { "location" => "london", "radius" => 10 },
             frequency: :daily)
    end

    before do
      allow(SetSubscriptionLocationDataJob).to receive(:perform_later)
    end

    context "when the location changes" do
      let(:new_attributes) { { search_criteria: { "location" => "manchester", "radius" => 10 } } }

      it "updathes the subscription search criteria with the new location info" do
        expect {
          update_with_search_criteria
          subscription.reload
        }.to change { subscription.search_criteria["location"] }.from("london").to("manchester")
      end

      it "enqueues SetSubscriptionLocationDataJob for the subscription" do
        update_with_search_criteria
        expect(SetSubscriptionLocationDataJob).to have_received(:perform_later).with(subscription)
      end
    end

    context "when the radius changes" do
      let(:new_attributes) { { search_criteria: { "location" => "london", "radius" => 20 } } }

      it "updathes the subscription search criteria with the new radius info" do
        expect {
          update_with_search_criteria
          subscription.reload
        }.to change { subscription.search_criteria["radius"] }.from(10).to(20)
      end

      it "enqueues SetSubscriptionLocationDataJob for the subscription" do
        update_with_search_criteria
        expect(SetSubscriptionLocationDataJob).to have_received(:perform_later).with(subscription)
      end
    end

    context "when the location criteria does not change" do
      let(:new_attributes) { { search_criteria: { "location" => "london", "radius" => 10, phases: %w[primary] } } }

      it "updathes the subscription search criteria" do
        expect {
          update_with_search_criteria
          subscription.reload
        }.to change { subscription.search_criteria["phases"] }.from(nil).to(%w[primary])
      end

      it "does not enqueue SetSubscriptionLocationDataJob for the subscription" do
        update_with_search_criteria
        expect(SetSubscriptionLocationDataJob).not_to have_received(:perform_later)
      end
    end

    context "when update is unsuccessful" do
      let(:new_attributes) { { search_criteria: { "location" => "manchester", "radius" => 20 } } }

      before do
        allow(subscription).to receive(:update).with(new_attributes).and_return(false)
      end

      it "does not enqueue SetSubscriptionLocationDataJob even if location criteria changes" do
        update_with_search_criteria
        expect(SetSubscriptionLocationDataJob).not_to have_received(:perform_later)
      end
    end
  end
end
