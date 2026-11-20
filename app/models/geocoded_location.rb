# Coordinates returned by the geocoding APIs, kept in a table rather than in Rails.cache.
# Looking a location up costs money, so results must outlive the Rails cache's short, FIFO-evicted lifetime.
class GeocodedLocation < ApplicationRecord
  FRESH_FOR = 180.days # The UK's geography is stable, and the volume of searches makes API calls expensive
  NO_MATCH_FRESH_FOR = 7.days
  RETENTION = 1.year # Rows older than FRESH_FOR are only kept as a fallback if the APIs fail

  validates :query, presence: true, uniqueness: true
  validates :geocoded_at, presence: true

  scope :past_retention, -> { where(geocoded_at: ...RETENTION.ago) }

  def self.normalise(query)
    query.to_s.squish.downcase
  end

  def self.store!(query, coordinates, geocoded_at: Time.current)
    now = Time.current
    upsert(
      { query: normalise(query),
        latitude: coordinates&.first,
        longitude: coordinates&.second,
        geocoded_at: geocoded_at,
        created_at: now,
        updated_at: now },
      unique_by: :query,
      update_only: %i[latitude longitude geocoded_at],
    )
  end

  def no_match?
    latitude.nil? || longitude.nil?
  end

  def coordinates
    [latitude, longitude] unless no_match?
  end

  def fresh?
    geocoded_at > (no_match? ? NO_MATCH_FRESH_FOR : FRESH_FOR).ago
  end
end
