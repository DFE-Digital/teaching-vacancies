require "rails_helper"

RSpec.describe DrivingTime do
  subject(:driving_time) { described_class.new(postcode: postcode, destination: destination) }

  let(:postcode) { "SW1A 1AA" }
  let(:destination) { GeoFactories::FACTORY_4326.point(-1.2, 51.5) }
  let(:response_body) { { routes: [{ duration: "1501s" }] }.to_json }

  before do
    stub_const("GOOGLE_LOCATION_SEARCH_API_KEY", "test-key")
    stub_request(:post, described_class::ENDPOINT).to_return(status: 200, body: response_body)
  end

  describe "#duration_in_minutes" do
    it "returns the driving duration rounded up to minutes" do
      expect(driving_time.duration_in_minutes).to eq(26)
    end

    it "sends the route request without exposing unnecessary response fields" do
      driving_time.duration_in_minutes

      expect(WebMock).to have_requested(:post, described_class::ENDPOINT)
        .with(
          headers: {
            "Content-Type" => "application/json",
            "X-Goog-Api-Key" => "test-key",
            "X-Goog-FieldMask" => "routes.duration",
          },
          body: {
            origin: { address: "SW1A 1AA, United Kingdom" },
            destination: {
              location: { latLng: { latitude: 51.5, longitude: -1.2 } },
            },
            travelMode: "DRIVE",
          }.to_json,
        )
    end

    context "with an invalid postcode" do
      let(:postcode) { "not a postcode" }

      it "raises an invalid postcode error without calling Google" do
        expect { driving_time.duration_in_minutes }.to raise_error(described_class::InvalidPostcodeError)
        expect(WebMock).not_to have_requested(:post, described_class::ENDPOINT)
      end
    end

    context "without vacancy coordinates" do
      let(:destination) { nil }

      it "raises a route not found error" do
        expect { driving_time.duration_in_minutes }.to raise_error(described_class::RouteNotFoundError)
      end
    end

    context "when Google does not return a route" do
      let(:response_body) { { routes: [] }.to_json }

      it "raises a route not found error" do
        expect { driving_time.duration_in_minutes }.to raise_error(described_class::RouteNotFoundError)
      end
    end

    context "when Google returns an unsuccessful response" do
      before do
        stub_request(:post, described_class::ENDPOINT)
          .to_return(status: 403, body: { error: { message: "Routes API is disabled" } }.to_json)
      end

      it "includes Google's error in the request error" do
        expect { driving_time.duration_in_minutes }
          .to raise_error(described_class::RequestError, "Google Routes API returned 403: Routes API is disabled")
      end
    end

    context "when the request cannot connect to Google" do
      before do
        stub_request(:post, described_class::ENDPOINT).to_raise(Faraday::ConnectionFailed)
      end

      it "raises a request error" do
        expect { driving_time.duration_in_minutes }.to raise_error(described_class::RequestError)
      end
    end
  end
end
