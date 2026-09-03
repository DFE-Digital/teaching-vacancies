require "rails_helper"

RSpec.describe CommuteTime do
  subject(:commute_time) do
    described_class.new(postcode: postcode, destination: destination, travel_mode: travel_mode)
  end

  let(:postcode) { "SW1A 1AA" }
  let(:destination) { GeoFactories::FACTORY_4326.point(-1.2, 51.5) }
  let(:travel_mode) { "driving" }
  let(:response_body) { { routes: [{ duration: "1501s" }] }.to_json }

  before do
    stub_const("GOOGLE_LOCATION_SEARCH_API_KEY", "test-key")
    stub_request(:post, described_class::ENDPOINT).to_return(status: 200, body: response_body)
  end

  describe ".valid_postcode?" do
    it "accepts a full UK postcode" do
      expect(described_class.valid_postcode?(" sw1a 1aa ")).to be(true)
    end

    it "rejects a town or city" do
      expect(described_class.valid_postcode?("Birmingham")).to be(false)
    end
  end

  describe ".valid_travel_mode?" do
    it "accepts supported travel modes" do
      expect(described_class.valid_travel_mode?("driving")).to be(true)
      expect(described_class.valid_travel_mode?("walking")).to be(true)
      expect(described_class.valid_travel_mode?("transit")).to be(true)
    end

    it "rejects unsupported travel modes" do
      expect(described_class.valid_travel_mode?("flying")).to be(false)
    end
  end

  describe "#duration_in_minutes" do
    it "returns the duration rounded up to minutes" do
      expect(commute_time.duration_in_minutes).to eq(26)
    end

    it "sends only the required route fields" do
      commute_time.duration_in_minutes

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

    described_class::TRAVEL_MODES.each do |mode, google_mode|
      context "when the travel mode is #{mode}" do
        let(:travel_mode) { mode }

        it "requests Google's #{google_mode} route" do
          commute_time.duration_in_minutes

          request_for_mode = have_requested(:post, described_class::ENDPOINT).with do |request|
            JSON.parse(request.body).fetch("travelMode") == google_mode
          end
          expect(WebMock).to request_for_mode
        end
      end
    end

    context "with an invalid postcode" do
      let(:postcode) { "not a postcode" }

      it "raises an invalid postcode error without calling Google" do
        expect { commute_time.duration_in_minutes }.to raise_error(described_class::InvalidPostcodeError)
        expect(WebMock).not_to have_requested(:post, described_class::ENDPOINT)
      end
    end

    context "with an unsupported travel mode" do
      let(:travel_mode) { "flying" }

      it "raises an invalid travel mode error without calling Google" do
        expect { commute_time.duration_in_minutes }.to raise_error(described_class::InvalidTravelModeError)
        expect(WebMock).not_to have_requested(:post, described_class::ENDPOINT)
      end
    end

    context "without vacancy coordinates" do
      let(:destination) { nil }

      it "raises a route not found error" do
        expect { commute_time.duration_in_minutes }.to raise_error(described_class::RouteNotFoundError)
      end
    end

    context "when Google does not return a route" do
      let(:response_body) { { routes: [] }.to_json }

      it "raises a route not found error" do
        expect { commute_time.duration_in_minutes }.to raise_error(described_class::RouteNotFoundError)
      end
    end

    context "when Google returns an unsuccessful response" do
      before do
        stub_request(:post, described_class::ENDPOINT)
          .to_return(status: 403, body: { error: { message: "Routes API is disabled" } }.to_json)
      end

      it "includes Google's error in the request error" do
        expect { commute_time.duration_in_minutes }
          .to raise_error(described_class::RequestError, "Google Routes API returned 403: Routes API is disabled")
      end
    end

    context "when the request cannot connect to Google" do
      before do
        stub_request(:post, described_class::ENDPOINT).to_raise(Faraday::ConnectionFailed)
      end

      it "raises a request error" do
        expect { commute_time.duration_in_minutes }.to raise_error(described_class::RequestError)
      end
    end
  end
end
