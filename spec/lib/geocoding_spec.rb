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

    context "when the location has a fresh stored row" do
      before { GeocodedLocation.store!("ts14 6rd", google_coordinates, geocoded_at: 10.days.ago) }

      it "returns the stored coordinates without calling the API" do
        expect(Geocoder).not_to receive(:coordinates)
        expect(subject.coordinates).to eq(google_coordinates)
      end

      it "does not trigger a Google Geocoding API hit event" do
        expect { subject.coordinates }.not_to have_enqueued_job(DfE::Analytics::SendEvents)
      end

      it "matches regardless of case and whitespace" do
        expect(described_class.new("  ts14   6RD ").coordinates).to eq(google_coordinates)
      end
    end

    context "when the location has a fresh stored no-match row" do
      before { GeocodedLocation.store!(location, nil, geocoded_at: 1.day.ago) }

      it "returns no_match without calling the API" do
        expect(Geocoder).not_to receive(:coordinates)
        expect(subject.coordinates).to eq(no_match)
      end
    end

    context "when the stored row is older than the freshness period" do
      before { GeocodedLocation.store!(location, [1.0, 2.0], geocoded_at: 200.days.ago) }

      context "when Google returns a valid response", vcr: { cassette_name: "geocoder_google_valid" } do
        it "refreshes the stored row" do
          expect(subject.coordinates).to eq(google_coordinates)
          expect(GeocodedLocation.find_by(query: "ts14 6rd")).to have_attributes(coordinates: google_coordinates, fresh?: true)
        end
      end

      context "when Google returns an empty response", vcr: { cassette_name: "geocoder_google_empty" } do
        it "returns the stale coordinates and marks the row as a no match" do
          expect(subject.coordinates).to eq([1.0, 2.0])
          expect(GeocodedLocation.find_by(query: "ts14 6rd")).to be_no_match
        end
      end

      context "when Google is over its query limit and Ordnance Survey returns nothing" do
        before do
          allow(Geocoder).to receive(:coordinates).with(location, lookup: :google, components: "country:gb").and_raise(Geocoder::OverQueryLimitError)
          allow(Geocoder).to receive(:coordinates).with(location, lookup: :uk_ordnance_survey_names).and_return(nil)
        end

        it "returns the stale coordinates and leaves the row untouched" do
          expect(subject.coordinates).to eq([1.0, 2.0])
          expect(GeocodedLocation.find_by(query: "ts14 6rd").coordinates).to eq([1.0, 2.0])
        end
      end
    end

    context "when the location only has a legacy Rails cache entry" do
      before { allow(Rails.cache).to receive(:read).with([:geocoding, location]).and_return(google_coordinates) }

      it "returns the cached coordinates without calling the API, and stores them" do
        expect(Geocoder).not_to receive(:coordinates)
        expect(subject.coordinates).to eq(google_coordinates)
        expect(GeocodedLocation.find_by(query: "ts14 6rd").coordinates).to eq(google_coordinates)
      end
    end

    context "when the location is blank" do
      let(:location) { "  " }

      it "returns no_match without calling the API" do
        expect(Geocoder).not_to receive(:coordinates)
        expect(subject.coordinates).to eq(no_match)
      end
    end

    context "when the location has no stored row" do
      context "when Geocoder with `lookup: :google` returns a valid response", vcr: { cassette_name: "geocoder_google_valid" } do
        it "returns the coordinates" do
          expect(subject.coordinates).to eq(google_coordinates)
        end

        it "stores the coordinates" do
          subject.coordinates
          expect(GeocodedLocation.find_by(query: "ts14 6rd").coordinates).to eq(google_coordinates)
        end

        it "triggers a Google Geocoding API hit event" do
          subject.coordinates
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_tvs_analytics_events_with_data(
            { type: "coordinates", location: location, result: google_coordinates.to_s },
          )
        end
      end

      context "when Geocoder with `lookup: :google` returns an empty response", vcr: { cassette_name: "geocoder_google_empty" } do
        it "returns no_match" do
          expect(subject.coordinates).to eq(no_match)
        end

        it "stores a no-match row so the API is not called again" do
          subject.coordinates
          expect(GeocodedLocation.find_by(query: "ts14 6rd")).to be_no_match
        end

        it "triggers a Google Geocoding API hit event" do
          subject.coordinates
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_tvs_analytics_events_with_data(
            { type: "coordinates", location: location, result: nil },
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
          expect(:google_geocoding_api_hit).to have_been_enqueued_as_tvs_analytics_events_with_data(
            { type: "coordinates", location: location, result: "OVER_QUERY_LIMIT" },
          )
        end

        context "when Geocoder with `lookup: :uk_ordnance_survey_names` returns a valid response" do
          it "returns the coordinates" do
            expect(subject.coordinates.map { |coord| coord.round(7) }).to eq(os_coordinates)
          end
        end

        context "when Geocoder with `lookup: :uk_ordnance_survey_names` returns an empty response" do
          before do
            allow(Geocoder).to receive(:coordinates).with(location, lookup: :google, components: "country:gb").and_raise(Geocoder::OverQueryLimitError)
            allow(Geocoder).to receive(:coordinates).with(location, lookup: :uk_ordnance_survey_names).and_return(nil)
          end

          it "returns no_match without storing a row" do
            expect(subject.coordinates).to eq(no_match)
            expect(GeocodedLocation.count).to eq(0)
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
end
# rubocop:enable RSpec/ExpectActual
