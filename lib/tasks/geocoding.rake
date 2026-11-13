namespace :geocoding do
  desc "Copy geocoding results from the Redis-backed Rails cache into the geocoded_locations table"
  task import_from_redis_cache: :environment do
    result = GeocodedLocations::ImportFromRedisCache.new.call
    puts "Imported #{result.imported} geocoded locations, skipped #{result.skipped}."
  end
end
