require "rails_helper"

RSpec.describe Geocoding, geocode: true do
  subject { described_class.new(location) }

  let(:location) { "TS14 6RD" }
  let(:google_coordinates) { [54.5399146, -1.0435559] }
  let(:os_coordinates) { [54.5411000, -1.0450614] }
  let(:no_match) { [0, 0] }

  describe "#coordinates" do
    context "when Geocoder with `lookup: :google` returns a valid response", vcr: { cassette_name: "geocoder_google_valid" } do
      it "returns the coordinates" do
        expect(subject.coordinates).to eq(google_coordinates)
      end

      it "caches the result" do
        expect(Rails.cache).to receive(:fetch)
        subject.coordinates
      end
    end

    context "when Geocoder with `lookup: :google` returns an empty response", vcr: { cassette_name: "geocoder_google_empty" } do
      it "returns no_match" do
        expect(subject.coordinates).to eq(no_match)
      end

      it "does not cache the result" do
        expect(Rails.cache).not_to receive(:fetch)
        subject.coordinates
      end
    end

    context "when Geocoder with `lookup: :google` returns status OVER_QUERY_LIMIT", vcr: { cassette_name: "geocoder_google_over_query_limit_os_valid" } do
      it "logs an error to Rollbar" do
        expect(Rollbar).to receive(:log).with(:error, "Google Geocoding API responded with OVER_QUERY_LIMIT")
        subject.coordinates
      end

      context "when Geocoder with `lookup: :uk_ordnance_survey_names` returns a valid response" do
        it "returns the coordinates" do
          expect(subject.coordinates.map { |coord| coord.round(7) }).to eq(os_coordinates)
        end

        it "caches the result" do
          expect(Rails.cache).to receive(:fetch)
          subject.coordinates
        end
      end

      context "when Geocoder with `lookup: :uk_ordnance_survey_names` returns an empty response", vcr: { cassette_name: "geocoder_google_over_query_limit_os_empty" } do
        it "returns no_match" do
          expect(subject.coordinates).to eq(no_match)
        end

        it "does not cache the result" do
          expect(Rails.cache).not_to receive(:fetch)
          subject.coordinates
        end
      end
    end
  end
end
