require "rails_helper"
require "geocoding"

# rubocop:disable RSpec/ExpectActual
RSpec.describe Geocoding, geocode: true do
  subject { described_class.new(location) }

  let(:google_coordinates) { [54.54109829999999, -1.0450767] }
  let(:location) { "TS14 6RD" }

  describe "#coordinates", :dfe_analytics do
    let(:no_match) { [0, 0] }
    let(:os_coordinates) { [54.5411, -1.0450614] }

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
      context "when Geocoder with `lookup: :google` returns a valid response", vcr: { cassette_name: "geocoder_google_valid" } do
        it "returns the coordinates" do
          expect(subject.coordinates).to eq(google_coordinates)
        end

        it "triggers a Google Geocoding API hit event" do
          subject.coordinates
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_analytics_event(
            with_data: { type: "coordinates", location: location, result: google_coordinates.to_s },
          )
        end
      end

      context "when Geocoder with `lookup: :google` returns an empty response", vcr: { cassette_name: "geocoder_google_empty" } do
        it "returns no_match" do
          expect(subject.coordinates).to eq(no_match)
        end

        it "triggers a Google Geocoding API hit event" do
          subject.coordinates
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_analytics_event(
            with_data: { type: "coordinates", location: location, result: nil },
          )
        end
      end

      context "when Geocoder with `lookup: :google` returns status OVER_QUERY_LIMIT", vcr: { cassette_name: "geocoder_google_over_query_limit_os_valid" } do
        it "logs an error" do
          expect(Rails.logger).to receive(:error).with("Google Geocoding API responded with OVER_QUERY_LIMIT")
          subject.coordinates
        end

        it "triggers a Google Geocoding API hit event" do
          subject.coordinates
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_analytics_event(
            with_data: { type: "coordinates", location: location, result: "OVER_QUERY_LIMIT" },
          )
        end

        context "when Geocoder with `lookup: :uk_ordnance_survey_names` returns a valid response" do
          it "returns the coordinates" do
            expect(subject.coordinates.map { |coord| coord.round(7) }).to eq(os_coordinates)
          end
        end

        context "when Geocoder with `lookup: :uk_ordnance_survey_names` returns an empty response", vcr: { cassette_name: "geocoder_google_over_query_limit_os_empty" } do
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
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_analytics_event(
            with_data: { type: "postcode", location: google_coordinates.to_s, result: postcode },
          )
        end
      end

      context "when Geocoder with `lookup: :google` returns an empty response", vcr: { cassette_name: "geocoder_google_postcode_lookup_empty" } do
        it "returns no match" do
          expect(subject.postcode_from_coordinates).to be_nil
        end

        it "triggers a Google Geocoding API hit event" do
          subject.postcode_from_coordinates
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_analytics_event(
            with_data: { type: "postcode", location: google_coordinates.to_s, result: nil },
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
        expect(:google_geocoding_api_hit).to have_been_enqueued_as_analytics_event(
          with_data: { type: "postcode", location: google_coordinates.to_s, result: "OVER_QUERY_LIMIT" },
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
