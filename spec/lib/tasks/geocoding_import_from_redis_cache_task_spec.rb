require "rails_helper"

RSpec.describe "geocoding:import_from_redis_cache" do
  let(:task_path) { "lib/tasks/geocoding" }
  let(:service) { instance_double(GeocodedLocations::ImportFromRedisCache, call: GeocodedLocations::ImportFromRedisCache::Result.new(3, 1)) }

  before { allow(GeocodedLocations::ImportFromRedisCache).to receive(:new).and_return(service) }

  # rubocop:disable RSpec/NamedSubject
  it "runs the import and reports the counts" do
    expect { subject.execute }.to output("Imported 3 geocoded locations, skipped 1.\n").to_stdout
  end
  # rubocop:enable RSpec/NamedSubject
end
