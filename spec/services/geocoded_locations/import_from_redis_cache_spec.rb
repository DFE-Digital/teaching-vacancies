require "rails_helper"

RSpec.describe GeocodedLocations::ImportFromRedisCache do
  subject(:result) { described_class.new(cache:).call }

  let(:redis) { instance_double(Redis) }
  let(:cache) { instance_double(ActiveSupport::Cache::RedisCacheStore, redis:) }
  let(:values) { {} }
  let(:ttls) { {} }

  before do
    allow(cache).to receive(:is_a?).with(ActiveSupport::Cache::RedisCacheStore).and_return(true)
    allow(redis).to receive(:then).and_yield(redis)
    allow(redis).to receive(:scan_each).and_return(values.keys.each)
    allow(cache).to receive(:read) { |key| values[key] }
    allow(redis).to receive(:ttl) { |key| ttls.fetch(key, 100.days.to_i) }
  end

  context "when the cache is not a Redis cache store" do
    let(:cache) { ActiveSupport::Cache::NullStore.new }

    before { allow(cache).to receive(:is_a?).and_call_original }

    it "refuses to run" do
      expect { result }.to raise_error(ArgumentError, /not a RedisCacheStore/)
    end
  end

  context "with cached entries" do
    let(:values) do
      {
        "geocoding/TS14 6RD" => [54.5, -1.0],
        "geocoding/ts14  6rd" => [54.6, -1.1],
        "geocoding/London" => [51.5, -0.1],
        "geocoding/Nowhere" => [0, 0],
        "geocoding/Missing" => nil,
        "geocoding/   " => [1.0, 2.0],
      }
    end
    let(:ttls) { { "geocoding/London" => 30.days.to_i, "geocoding/TS14 6RD" => 50.days.to_i, "geocoding/ts14  6rd" => 100.days.to_i } }

    it "imports valid entries, keeping the most recent of the entries that normalise to the same query" do
      expect(result).to have_attributes(imported: 2, skipped: 4)
      expect(GeocodedLocation.find_by(query: "ts14 6rd").coordinates).to eq([54.6, -1.1])
      expect(GeocodedLocation.find_by(query: "london").coordinates).to eq([51.5, -0.1])
    end

    it "preserves the remaining lifetime of each entry" do
      result
      expect(GeocodedLocation.find_by(query: "london").geocoded_at).to be_within(1.minute).of(150.days.ago)
    end

    it "does not overwrite rows already in the table" do
      GeocodedLocation.store!("london", [9.0, 9.0])

      result

      expect(GeocodedLocation.find_by(query: "london").coordinates).to eq([9.0, 9.0])
    end
  end

  context "when an entry has no expiry" do
    let(:values) { { "geocoding/London" => [51.5, -0.1] } }
    let(:ttls) { { "geocoding/London" => -1 } }

    it "treats it as freshly geocoded" do
      result
      expect(GeocodedLocation.first.geocoded_at).to be_within(1.minute).of(Time.current)
    end
  end
end
