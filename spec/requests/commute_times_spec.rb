require "rails_helper"

RSpec.describe "Commute times" do
  let(:vacancy) { create(:vacancy) }
  let(:driving_time) { instance_double(DrivingTime, duration_in_minutes: 26) }

  before do
    allow(DrivingTime).to receive(:new)
      .with(postcode: "SW1A 1AA", destination: vacancy.geolocation)
      .and_return(driving_time)
  end

  describe "POST /jobs/:job_id/commute-time" do
    subject(:request) do
      post job_commute_time_path(vacancy), params: { postcode: "SW1A 1AA" }
    end

    it "renders the driving time" do
      request

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("26 minutes by car")
      expect(response.body).to include("Google Maps")
    end

    context "with an invalid postcode" do
      before do
        allow(driving_time).to receive(:duration_in_minutes).and_raise(DrivingTime::InvalidPostcodeError)
      end

      it "returns a useful error" do
        request

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq("error" => "Enter a full UK postcode")
      end
    end

    context "when no driving route can be found" do
      before do
        allow(driving_time).to receive(:duration_in_minutes).and_raise(DrivingTime::RouteNotFoundError)
      end

      it "returns a useful error" do
        request

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq("error" => "We could not find a driving route from that postcode.")
      end
    end

    context "when Google is unavailable" do
      before do
        allow(driving_time).to receive(:duration_in_minutes)
          .and_raise(DrivingTime::RequestError, "Google Routes API returned 403: Routes API is disabled")
      end

      it "returns a temporary error" do
        expect(Rails.logger).to receive(:error)
          .with("Driving time request failed: Google Routes API returned 403: Routes API is disabled")

        request
        expect(response).to have_http_status(:bad_gateway)
        expect(response.parsed_body).to eq("error" => "We could not calculate the driving time. Try again later.")
      end
    end
  end
end
