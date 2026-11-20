require "rails_helper"

RSpec.describe PurgeStaleGeocodedLocationsJob do
  it "deletes only the rows older than the retention period" do
    GeocodedLocation.store!("old", [1.0, 2.0], geocoded_at: 2.years.ago)
    GeocodedLocation.store!("stale but retained", [1.0, 2.0], geocoded_at: 200.days.ago)

    described_class.perform_now

    expect(GeocodedLocation.pluck(:query)).to eq(["stale but retained"])
  end
end
