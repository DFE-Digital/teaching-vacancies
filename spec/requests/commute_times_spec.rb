require "rails_helper"

RSpec.describe "Commute times" do
  let(:vacancy) { create(:vacancy) }
  let(:search_location) { "SW1A 1AA" }
  let(:travel_mode) { "driving" }
  let(:commute_time) { instance_double(CommuteTime, duration_in_minutes: 26) }

  before do
    allow(CommuteTime).to receive(:new)
      .with(postcode: search_location.upcase, destination: vacancy.geolocation, travel_mode: travel_mode)
      .and_return(commute_time)
  end

  describe "GET /jobs/:job_id/commute-time" do
    subject(:request) do
      get job_commute_time_path(vacancy), params: { search_location: search_location, travel_mode: travel_mode }
    end

    it "renders the commute time in the travel mode's Turbo Frame" do
      request

      expect(response).to have_http_status(:ok)
      expect(Capybara.string(response.body)).to have_css("turbo-frame#commute_time_vacancy_#{vacancy.id}_driving")
      expect(response.body).to include("26 minutes")
    end

    context "with an invalid postcode" do
      let(:search_location) { "not a postcode" }

      before do
        allow(commute_time).to receive(:duration_in_minutes).and_raise(CommuteTime::InvalidPostcodeError)
      end

      it "renders a useful error in the frame" do
        request

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Enter a full UK postcode")
      end
    end

    context "when no route can be found" do
      before do
        allow(commute_time).to receive(:duration_in_minutes).and_raise(CommuteTime::RouteNotFoundError)
      end

      it "renders a useful error in the frame" do
        request

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Not available")
      end
    end

    context "when Google is unavailable" do
      before do
        allow(commute_time).to receive(:duration_in_minutes)
          .and_raise(CommuteTime::RequestError, "Google Routes API returned 403: Routes API is disabled")
      end

      it "logs the details and renders a safe error in the frame" do
        expect(Rails.logger).to receive(:error)
          .with("Commute time request failed for driving: Google Routes API returned 403: Routes API is disabled")

        request
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Not available")
      end
    end

    context "with an unsupported travel mode" do
      let(:travel_mode) { "flying" }

      before do
        allow(commute_time).to receive(:duration_in_minutes).and_raise(CommuteTime::InvalidTravelModeError)
      end

      it "renders a useful error in the frame" do
        request

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Not available")
      end
    end
  end
end
