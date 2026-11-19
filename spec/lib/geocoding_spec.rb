require "rails_helper"
require "geocoding"

# rubocop:disable RSpec/ExpectActual
RSpec.describe Geocoding, geocode: true do
  subject { described_class.new(location) }

  let(:google_coordinates) { [54.54109829999999, -1.0450767] }
  let(:location) { "TS14 6RD" }

  describe "#coordinates", :dfe_analytics do
    let(:no_match) { [0, 0] }

    context "when location has a cache entry" do
      before do
        allow(Rails.cache)
          .to receive(:fetch)
          .with([:geocoding, location], expires_in: Geocoding::CACHE_DURATION, skip_nil: true)
          .and_return(google_coordinates)
      end

      it "retrieves coordinates from the cache" do
        expect(subject.coordinates).to eq(google_coordinates)
      end

      it "does not call `Geocoder.coordinates`" do
        expect(Geocoder).not_to receive(:coordinates)
        subject.coordinates
      end

      it "does not trigger a Google Geocoding API hit event" do
        expect { subject.coordinates }.not_to have_sent_analytics_event_types(:google_geocoding_api_hit)
      end
    end

    context "when location does not have a cache entry" do
      let(:os_url) { %r{api\.os\.uk/search/names/v1/find} }
      let!(:google_stub) { stub_request(:get, google_url).to_return(google_response) }
      let(:google_url) { %r{maps\.googleapis\.com/maps/api/geocode/json} }
      let(:os_entries) { [os_entry] }
      let(:os_entry) do
        { "NAME1" => "TS14 6RD",
          "LOCAL_TYPE" => "Postcode",
          "COUNTRY" => "England",
          "GEOMETRY_X" => 462_000,
          "GEOMETRY_Y" => 516_000,
          "DISTRICT_BOROUGH" => "Redcar and Cleveland" }
      end
      let(:os_response) { { status: 200, body: os_body(os_entries) } }
      let(:google_response) do
        { status: 200, body: { status: "OK", results: [{ geometry: { location: { lat: 54.54109829999999, lng: -1.0450767 } } }] }.to_json }
      end

      def os_body(entries)
        { header: { totalresults: entries.size }, results: entries.map { |entry| { "GAZETTEER_ENTRY" => entry } } }.to_json
      end

      before do
        stub_request(:get, os_url).to_return(os_response)
      end

      context "when Ordnance Survey returns a matching result" do
        it "returns the Ordnance Survey coordinates without calling Google" do
          expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 462_000, northing: 516_000).lat_lng)
          expect(google_stub).not_to have_been_requested
        end

        it "does not trigger a Google Geocoding API hit event" do
          expect(DfE::Analytics::SendEvents).not_to receive(:do)
          subject.coordinates
        end
      end

      context "when Ordnance Survey returns a match outside England" do
        let(:os_entries) { [os_entry.merge("COUNTRY" => "Wales")] }

        it "falls back to Google" do
          expect(subject.coordinates).to eq(google_coordinates)
        end
      end

      context "when the Ordnance Survey result has a different name" do
        let(:os_entries) { [os_entry.merge("NAME1" => "Edinburgh Farm")] }

        it "falls back to Google" do
          expect(subject.coordinates).to eq(google_coordinates)
        end
      end

      context "when the location includes a county and the name matches case-insensitively" do
        let(:location) { "ts14 6rd, Redcar and Cleveland" }

        it "returns the Ordnance Survey coordinates" do
          expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 462_000, northing: 516_000).lat_lng)
        end
      end

      context "when the location includes a matching county for an ambiguous place name" do
        let(:location) { "Newport, Isle of Wight" }
        let(:os_entries) do
          [os_entry.merge("NAME1" => "Newport", "LOCAL_TYPE" => "Town", "COUNTY_UNITARY" => "Isle of Wight")]
        end

        it "returns the matching Ordnance Survey coordinates" do
          expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 462_000, northing: 516_000).lat_lng)
        end
      end

      context "when the location includes a county that does not match the Ordnance Survey result" do
        let(:location) { "Newport, Wales" }
        let(:os_entries) do
          [os_entry.merge("NAME1" => "Newport", "LOCAL_TYPE" => "Town", "COUNTY_UNITARY" => "Isle of Wight")]
        end

        it "falls back to Google" do
          expect(subject.coordinates).to eq(google_coordinates)
        end
      end

      context "when Ordnance Survey returns nothing" do
        let(:os_entries) { [] }

        it "falls back to Google" do
          expect(subject.coordinates).to eq(google_coordinates)
        end
      end

      context "when Ordnance Survey errors" do
        let(:os_response) { { status: 500, body: "" } }

        it "falls back to Google" do
          expect(subject.coordinates).to eq(google_coordinates)
        end
      end

      context "when Ordnance Survey returns an error body without a header" do
        let(:os_response) { { status: 200, body: { error: "Unauthorized" }.to_json } }

        it "logs the failure and falls back to Google" do
          expect(Rails.logger).to receive(:error).with("Ordnance Survey Names API lookup failed: NoMethodError")
          expect(subject.coordinates).to eq(google_coordinates)
        end
      end

      context "when the Ordnance Survey API key is blank" do
        before do
          allow(Geocoder).to receive(:config_for_lookup).and_call_original
          allow(Geocoder).to receive(:config_for_lookup)
            .with(:uk_ordnance_survey_names)
            .and_return({ api_key: "" })
        end

        it "skips Ordnance Survey and falls back to Google" do
          expect(subject.coordinates).to eq(google_coordinates)
          expect(a_request(:get, os_url)).not_to have_been_made
        end
      end

      context "when the first Ordnance Survey result is outside England" do
        let(:os_entries) do
          [
            os_entry.merge("COUNTRY" => "Wales", "GEOMETRY_X" => 331_000, "GEOMETRY_Y" => 188_000),
            os_entry.merge("GEOMETRY_X" => 450_100, "GEOMETRY_Y" => 89_100),
          ]
        end

        it "uses the first result in England" do
          expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 450_100, northing: 89_100).lat_lng)
          expect(google_stub).not_to have_been_requested
        end
      end

      context "when a hamlet and a town share the searched name" do
        let(:location) { "Ashford" }
        let(:os_entries) do
          [
            os_entry.merge("NAME1" => "Ashford", "LOCAL_TYPE" => "Hamlet", "GEOMETRY_X" => 300_000, "GEOMETRY_Y" => 100_000),
            os_entry.merge("NAME1" => "Ashford", "LOCAL_TYPE" => "Town", "GEOMETRY_X" => 601_000, "GEOMETRY_Y" => 142_000),
          ]
        end

        it "prefers the town without calling Google" do
          expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 601_000, northing: 142_000).lat_lng)
          expect(google_stub).not_to have_been_requested
        end
      end

      context "when only a hamlet matches the searched name" do
        let(:location) { "Ashford" }
        let(:os_entries) { [os_entry.merge("NAME1" => "Ashford", "LOCAL_TYPE" => "Hamlet")] }

        it "uses the hamlet without calling Google" do
          expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 462_000, northing: 516_000).lat_lng)
          expect(google_stub).not_to have_been_requested
        end
      end

      context "when the matching results have an unknown or missing local type" do
        let(:location) { "Ashford" }
        let(:os_entries) do
          [
            os_entry.merge("NAME1" => "Ashford", "LOCAL_TYPE" => nil, "GEOMETRY_X" => 300_000, "GEOMETRY_Y" => 100_000),
            os_entry.merge("NAME1" => "Ashford", "LOCAL_TYPE" => "Hamlet", "GEOMETRY_X" => 601_000, "GEOMETRY_Y" => 142_000),
          ]
        end

        it "ranks them below a known type" do
          expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 601_000, northing: 142_000).lat_lng)
        end
      end

      context "when a suburb and two villages share the searched name" do
        let(:location) { "Clapham" }
        let(:os_entries) do
          [
            os_entry.merge("NAME1" => "Clapham", "LOCAL_TYPE" => "Village", "GEOMETRY_X" => 410_000, "GEOMETRY_Y" => 460_000),
            os_entry.merge("NAME1" => "Clapham", "LOCAL_TYPE" => "Suburban_Area", "GEOMETRY_X" => 530_000, "GEOMETRY_Y" => 175_000),
            os_entry.merge("NAME1" => "Clapham", "LOCAL_TYPE" => "Village", "GEOMETRY_X" => 503_000, "GEOMETRY_Y" => 252_000),
          ]
        end

        it "uses the suburb without calling Google" do
          expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 530_000, northing: 175_000).lat_lng)
          expect(google_stub).not_to have_been_requested
        end
      end

      context "when two towns share the searched name" do
        let(:location) { "Ashford" }
        let(:os_entries) do
          [
            os_entry.merge("NAME1" => "Ashford", "LOCAL_TYPE" => "Town", "GEOMETRY_X" => 601_000, "GEOMETRY_Y" => 142_000),
            os_entry.merge("NAME1" => "Ashford", "LOCAL_TYPE" => "Town", "GEOMETRY_X" => 507_000, "GEOMETRY_Y" => 171_000),
          ]
        end

        it "leaves the choice to Google" do
          expect(subject.coordinates).to eq(google_coordinates)
        end
      end

      context "when a more important place with the searched name is outside England" do
        let(:location) { "Newport" }
        let(:os_entries) do
          [
            os_entry.merge("NAME1" => "Newport", "LOCAL_TYPE" => "Town", "COUNTRY" => "England"),
            os_entry.merge("NAME1" => "Newport", "LOCAL_TYPE" => "City", "COUNTRY" => "Wales"),
          ]
        end

        it "leaves the choice to Google" do
          expect(subject.coordinates).to eq(google_coordinates)
        end
      end

      context "when no result has the searched name" do
        let(:location) { "Nowhere" }

        it "falls back to Google" do
          expect(subject.coordinates).to eq(google_coordinates)
        end
      end

      context "when the search ends with a country, as suggested by Google Places autocomplete" do
        let(:location) { "Clapham, London, UK" }
        let(:os_entries) do
          [os_entry.merge("NAME1" => "Clapham", "LOCAL_TYPE" => "Suburban_Area", "REGION" => "London")]
        end

        it "ignores the country and uses Ordnance Survey" do
          expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 462_000, northing: 516_000).lat_lng)
          expect(google_stub).not_to have_been_requested
        end
      end

      context "when the search is only a country" do
        let(:location) { "UK" }

        it "does not use Ordnance Survey" do
          expect(subject.coordinates).to eq(google_coordinates)
        end
      end

      context "when the search is an address with a postcode" do
        let(:location) { "1 High Street, Leeds, LS1 1AA" }
        let(:os_entries) { [os_entry.merge("NAME1" => "LS1 1AA")] }

        it "asks Ordnance Survey for the postcode only and uses its result" do
          expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 462_000, northing: 516_000).lat_lng)
          expect(a_request(:get, os_url).with(query: hash_including("query" => "LS1 1AA"))).to have_been_made
          expect(google_stub).not_to have_been_requested
        end

        context "when Ordnance Survey has no exact postcode match" do
          let(:os_entries) { [os_entry.merge("NAME1" => "LS1 1AB")] }

          it "falls back to Google with the full address" do
            expect(subject.coordinates).to eq(google_coordinates)
            expect(a_request(:get, google_url).with(query: hash_including("address" => location))).to have_been_made
          end
        end
      end

      context "when the search is a place name" do
        let(:location) { "Newport, Isle of Wight" }
        let(:os_entries) { [os_entry.merge("NAME1" => "Newport", "LOCAL_TYPE" => "Town", "COUNTY_UNITARY" => "Isle of Wight")] }

        it "asks Ordnance Survey for the first part only, including suburbs" do
          subject.coordinates
          expect(
            a_request(:get, os_url).with(query: hash_including("query" => "Newport", "fq" => a_string_including("local_type:Suburban_Area"))),
          ).to have_been_made
        end
      end

      {
        "Stoke on Trent" => "Stoke-on-Trent",
        "St. Albans" => "St Albans",
        "King’s Lynn" => "King's Lynn",
      }.each do |searched, os_name|
        context "when '#{searched}' is searched and Ordnance Survey names it '#{os_name}'" do
          let(:location) { searched }
          let(:os_entries) { [os_entry.merge("NAME1" => os_name, "LOCAL_TYPE" => "Town")] }

          it "matches without calling Google" do
            expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 462_000, northing: 516_000).lat_lng)
            expect(google_stub).not_to have_been_requested
          end
        end
      end

      context "when Ordnance Survey finds nothing and Google returns an empty response" do
        let(:os_entries) { [] }
        let(:google_response) { { status: 200, body: { status: "ZERO_RESULTS", results: [] }.to_json } }

        it "returns no_match and triggers a Google Geocoding API hit event" do
          expect(subject.coordinates).to eq(no_match)
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_tvs_analytics_events_with_data(
            { type: "coordinates", location: location, result: nil },
          )
        end
      end

      context "when Ordnance Survey has no exact match and Google returns status OVER_QUERY_LIMIT" do
        let(:os_entries) { [os_entry.merge("NAME1" => "A different name")] }
        let(:google_response) { { status: 200, body: { status: "OVER_QUERY_LIMIT", results: [] }.to_json } }

        it "falls back to the first Ordnance Survey result and logs an error" do
          allow(Rails.logger).to receive(:error)
          expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 462_000, northing: 516_000).lat_lng)
          expect(Rails.logger).to have_received(:error).with("Google Geocoding API responded with OVER_QUERY_LIMIT")
        end

        it "does not cache the fallback result" do
          allow(Rails.cache).to receive(:write)
          subject.coordinates
          expect(Rails.cache).not_to have_received(:write)
        end

        it "triggers a Google Geocoding API hit event" do
          subject.coordinates
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_tvs_analytics_events_with_data(
            { type: "coordinates", location: location, result: "OVER_QUERY_LIMIT" },
          )
        end

        context "when the first Ordnance Survey result is outside England" do
          let(:os_entries) do
            [
              os_entry.merge("NAME1" => "Cardiff", "COUNTRY" => "Wales", "GEOMETRY_X" => 318_000, "GEOMETRY_Y" => 177_000),
              os_entry.merge("NAME1" => "Other", "GEOMETRY_X" => 450_100, "GEOMETRY_Y" => 89_100),
            ]
          end

          it "uses the first result in England" do
            expect(subject.coordinates).to eq(Geocoder::EastingNorthing.new(easting: 450_100, northing: 89_100).lat_lng)
          end
        end

        context "when every Ordnance Survey result is outside England" do
          let(:os_entries) { [os_entry.merge("COUNTRY" => "Wales")] }

          it "returns no_match" do
            expect(subject.coordinates).to eq(no_match)
          end
        end

        context "when Ordnance Survey returns no results" do
          let(:os_entries) { [] }

          it "returns no_match" do
            expect(subject.coordinates).to eq(no_match)
          end
        end
      end
    end
  end

  describe "#uk_coordinates?" do
    let(:geocoding_instance) { described_class.new(location) }

    before do
      allow(geocoding_instance).to receive(:coordinates).and_return(coordinates)
    end

    subject { geocoding_instance.uk_coordinates? }

    context "when location is within the United Kingdom" do
      let(:location) { "London" }
      let(:coordinates) { [51.5074, -0.1278] }

      it { is_expected.to be true }
    end

    context "when location returns no coordinates" do
      let(:location) { "Madrid" }
      let(:coordinates) { Geocoding::COORDINATES_NO_MATCH }

      it { is_expected.to be false }
    end

    context "when the location returns the default GB centroid coordinates" do
      let(:coordinates) { Geocoding::COORDINATES_UK_CENTROID }

      context "when the provided location is outside the UK" do
        let(:location) { "Madrid" }

        it { is_expected.to be false }
      end

      (described_class::ACCEPTED_UK_CENTROID_LOCATIONS + ["U.K.", "G.B.", "U.K", "G.B"]).each do |uk_name|
        context "when the location is '#{uk_name}'" do
          let(:location) { uk_name }

          it { is_expected.to be true }
        end
      end
    end
  end

  describe "#postcode_from_coordinates", :dfe_analytics do
    let(:coordinates) { google_coordinates }
    let(:postcode) { "TS14 6RE" }

    subject { described_class.new(coordinates) }

    context "when the coordinates have a cache entry" do
      before do
        allow(Rails.cache)
          .to receive(:fetch)
                .with([:postcode_from_coords, coordinates], expires_in: Geocoding::CACHE_DURATION, skip_nil: true)
                .and_return(postcode)
      end

      it "retrieves coordinates from the cache" do
        expect(subject.postcode_from_coordinates).to eq(postcode)
      end

      it "does not call `Geocoder.search`" do
        expect(Geocoder).not_to receive(:search)
        subject.postcode_from_coordinates
      end

      it "does not trigger a Google Geocoding API hit event" do
        expect { subject.postcode_from_coordinates }.not_to have_sent_analytics_event_types(:google_geocoding_api_hit)
      end
    end

    context "when the coordinates do not have a cache entry" do
      context "when Geocoder with `lookup: :google` returns a valid response", vcr: { cassette_name: "geocoder_google_postcode_lookup_valid" } do
        it "returns the postcode" do
          expect(subject.postcode_from_coordinates).to eq(postcode)
        end

        it "triggers a Google Geocoding API hit event" do
          subject.postcode_from_coordinates
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_tvs_analytics_events_with_data(
            { type: "postcode", location: google_coordinates.to_s, result: postcode },
          )
        end
      end

      context "when Geocoder with `lookup: :google` returns an empty response", vcr: { cassette_name: "geocoder_google_postcode_lookup_empty" } do
        it "returns no match" do
          expect(subject.postcode_from_coordinates).to be_nil
        end

        it "triggers a Google Geocoding API hit event" do
          subject.postcode_from_coordinates
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_tvs_analytics_events_with_data(
            { type: "postcode", location: google_coordinates.to_s, result: nil },
          )
        end
      end
    end

    context "when Geocoder with `lookup: :google` returns status OVER_QUERY_LIMIT", vcr: { cassette_name: "geocoder_google_postcode_lookup_over_query_limit_openstreetmap_valid" } do
      it "logs an error" do
        expect(Rails.logger).to receive(:error).with("Google Geocoding API responded with OVER_QUERY_LIMIT")
        subject.postcode_from_coordinates
      end

      it "triggers a Google Geocoding API hit event" do
        subject.postcode_from_coordinates
        expect(:google_geocoding_api_hit).to have_been_enqueued_as_tvs_analytics_events_with_data(
          { type: "postcode", location: google_coordinates.to_s, result: "OVER_QUERY_LIMIT" },
        )
      end

      context "when Geocoder with `lookup: :nominatim` returns a valid response" do
        it "returns the postcode" do
          expect(subject.postcode_from_coordinates).to eq("TS14 6RD")
        end
      end

      context "when Geocoder with `lookup: :nominatim` returns an empty response", vcr: { cassette_name: "geocoder_google_postcode_lookup_over_query_limit_openstreetmap_empty" } do
        it "logs an error" do
          expect(Rails.logger).to receive(:error).with("Google Geocoding API responded with OVER_QUERY_LIMIT").ordered
          expect(Rails.logger).to receive(:error).with("Geocoding Nominatim API responded with error: Unable to geocode").ordered
          subject.postcode_from_coordinates
        end

        it "returns nil" do
          expect(subject.postcode_from_coordinates).to be_nil
        end
      end
    end
  end
end
# rubocop:enable RSpec/ExpectActual
