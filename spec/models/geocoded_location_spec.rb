require "rails_helper"

RSpec.describe GeocodedLocation do
  describe ".normalise" do
    it "strips, squishes and downcases" do
      expect(described_class.normalise("  Ts14   6RD ")).to eq("ts14 6rd")
    end

    it "handles nil" do
      expect(described_class.normalise(nil)).to eq("")
    end
  end

  describe ".store!" do
    it "creates a row under the normalised query" do
      described_class.store!(" London ", [51.5, -0.1])

      expect(described_class.find_by(query: "london")).to have_attributes(latitude: 51.5, longitude: -0.1)
    end

    it "updates the coordinates and timestamp of an existing row" do
      described_class.store!("london", [1.0, 2.0], geocoded_at: 200.days.ago)
      described_class.store!("London", [51.5, -0.1])

      expect(described_class.count).to eq(1)
      expect(described_class.first).to have_attributes(coordinates: [51.5, -0.1], fresh?: true)
    end

    it "stores a no-match row when there are no coordinates" do
      described_class.store!("nowhere", nil)

      expect(described_class.first).to be_no_match
    end
  end

  describe "#fresh?" do
    it "is true for coordinates stored within 180 days" do
      expect(described_class.new(latitude: 1, longitude: 2, geocoded_at: 179.days.ago)).to be_fresh
    end

    it "is false for coordinates stored over 180 days ago" do
      expect(described_class.new(latitude: 1, longitude: 2, geocoded_at: 181.days.ago)).not_to be_fresh
    end

    it "uses the shorter period for no-match rows" do
      expect(described_class.new(geocoded_at: 6.days.ago)).to be_fresh
      expect(described_class.new(geocoded_at: 8.days.ago)).not_to be_fresh
    end
  end

  describe ".past_retention" do
    it "returns only rows older than the retention period" do
      described_class.store!("old", [1.0, 2.0], geocoded_at: 2.years.ago)
      described_class.store!("recent", [1.0, 2.0], geocoded_at: 200.days.ago)

      expect(described_class.past_retention.pluck(:query)).to eq(%w[old])
    end
  end
end
