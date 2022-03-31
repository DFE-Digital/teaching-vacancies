class LocationLandingPage < LandingPage
  attr_reader :location

  def self.exists?(location)
    # TODO: This is the logic that previously was in the routes, should be tidied up
    # Landing page slugs may only contain lowercase characters and dashes
    # (avoids duplicate landing pages for e.g. "Narnia" and "narnia")
    location.match?(/^[a-z-]+$/) && LocationPolygon.include?(location.titleize)
  end

  def self.[](location)
    raise "No such location landing page: '#{location}'" unless exists?(location)

    new(location)
  end

  def initialize(location)
    @location = location
    @criteria = { location: name }
  end

  def name
    (MAPPED_LOCATIONS[location.tr("-", " ")] || location).titleize.gsub(/\bAnd\b/, "and")
  end

  private

  def cache_key
    [:location_landing_page_count, location]
  end

  def translation_args
    super.merge(
      scope: [:landing_pages, "_location"],
      location: name,
    )
  end
end
