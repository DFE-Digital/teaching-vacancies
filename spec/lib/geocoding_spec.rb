require "rails_helper"
require "geocoding"

RSpec.describe Geocoding, geocode: true do
  subject { described_class.new(location) }

  let(:google_coordinates) { [54.5399146, -1.0435559] }
  let(:location) { "TS14 6RD" }

  describe "#coordinates" do
    let(:no_match) { [0, 0] }
    let(:os_coordinates) { [54.5411000, -1.0450614] }

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
    end

    context "when location does not have a cache entry" do
      context "when Geocoder with `lookup: :google` returns a valid response", vcr: { cassette_name: "geocoder_google_valid" } do
        it "returns the coordinates" do
          expect(subject.coordinates).to eq(google_coordinates)
        end
      end

      context "when Geocoder with `lookup: :google` returns an empty response", vcr: { cassette_name: "geocoder_google_empty" } do
        it "returns no_match" do
          expect(subject.coordinates).to eq(no_match)
        end
      end

      context "when Geocoder with `lookup: :google` returns status OVER_QUERY_LIMIT", vcr: { cassette_name: "geocoder_google_over_query_limit_os_valid" } do
        it "logs an error to Rollbar" do
          expect(Rails.logger).to receive(:error).with("Google Geocoding API responded with OVER_QUERY_LIMIT")
          subject.coordinates
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

  describe "#postcode_from_coordinates" do
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
    end

    context "when the coordinates do not have a cache entry" do
      context "when Geocoder with `lookup: :google` returns a valid response", vcr: { cassette_name: "geocoder_google_postcode_lookup_valid" } do
        it "returns the postcode" do
          expect(subject.postcode_from_coordinates).to eq(postcode)
        end
      end

      context "when Geocoder with `lookup: :google` returns an empty response", vcr: { cassette_name: "geocoder_google_postcode_lookup_empty" } do
        it "returns no match" do
          expect(subject.postcode_from_coordinates).to be_nil
        end
      end
    end

    context "when Geocoder with `lookup: :google` returns status OVER_QUERY_LIMIT", vcr: { cassette_name: "geocoder_google_postcode_lookup_over_query_limit_openstreetmap_valid" } do
      it "logs an error to Rollbar" do
        expect(Rails.logger).to receive(:error).with("Google Geocoding API responded with OVER_QUERY_LIMIT")
        subject.postcode_from_coordinates
      end

      context "when Geocoder with `lookup: :nominatim` returns a valid response" do
        it "returns the postcode" do
          expect(subject.postcode_from_coordinates).to eq("TS14 6RD")
        end
      end

      context "when Geocoder with `lookup: :nominatim` returns an empty response", vcr: { cassette_name: "geocoder_google_postcode_lookup_over_query_limit_openstreetmap_empty" } do
        it "logs an error to Rollbar" do
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
