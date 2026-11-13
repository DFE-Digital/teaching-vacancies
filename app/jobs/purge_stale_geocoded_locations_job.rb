class PurgeStaleGeocodedLocationsJob < ApplicationJob
  queue_as :low

  def perform
    GeocodedLocation.past_retention.in_batches.delete_all
  end
end
