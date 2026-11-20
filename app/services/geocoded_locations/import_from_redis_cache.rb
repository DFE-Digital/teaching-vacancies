module GeocodedLocations
  # One-off migration of geocoding results from the Redis-backed Rails cache into the geocoded_locations table.
  # Each entry keeps its remaining lifetime, and rows already in the table are never overwritten.
  class ImportFromRedisCache
    KEY_PREFIX = "geocoding/".freeze
    BATCH_SIZE = 1000

    Result = Struct.new(:imported, :skipped)

    def initialize(cache: Rails.cache)
      @cache = cache
    end

    def call
      raise ArgumentError, "Rails.cache is not a RedisCacheStore" unless cache.is_a?(ActiveSupport::Cache::RedisCacheStore)

      result = Result.new(imported: 0, skipped: 0)
      cache.redis.then do |redis|
        redis.scan_each(match: "#{KEY_PREFIX}*", count: BATCH_SIZE).each_slice(BATCH_SIZE) do |keys|
          import_batch(redis, keys, result)
        end
      end
      result
    end

    private

    attr_reader :cache

    def import_batch(redis, keys, result)
      # Different raw keys can normalise to the same query: keep the most recent
      rows = keys.filter_map { |key| row_for(redis, key) }
                 .group_by { |row| row[:query] }
                 .map { |_query, group| group.max_by { |row| row[:geocoded_at] } }
      imported = rows.empty? ? 0 : GeocodedLocation.insert_all(rows, unique_by: :query).length
      result.imported += imported
      result.skipped += keys.size - imported
    end

    def row_for(redis, key)
      coordinates = cache.read(key)
      query = GeocodedLocation.normalise(key.delete_prefix(KEY_PREFIX))
      return if query.blank? || !valid_coordinates?(coordinates)

      ttl = redis.ttl(key)
      remaining = ttl.positive? ? ttl.seconds : GeocodedLocation::FRESH_FOR
      geocoded_at = Time.current - (GeocodedLocation::FRESH_FOR - [remaining, GeocodedLocation::FRESH_FOR].min)
      now = Time.current

      { query:, latitude: coordinates.first, longitude: coordinates.second, geocoded_at:, created_at: now, updated_at: now }
    end

    def valid_coordinates?(coordinates)
      coordinates.is_a?(Array) && coordinates.size == 2 && coordinates.all?(Numeric) && coordinates != Geocoding::COORDINATES_NO_MATCH
    end
  end
end
