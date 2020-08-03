class ImportPolygons
  attr_reader :location_type

  def initialize(location_type:)
    @location_type = location_type
  end

  def call
    response = HTTParty.get(LOCATION_POLYGON_SETTINGS[location_type][:api])

    response.fetch('features', []).each do |region_response|
      region_name = region_response.dig('attributes', LOCATION_POLYGON_SETTINGS[location_type][:name_key]).downcase

      next unless location_categories_include?(region_name)

      geometry_rings = region_response.dig('geometry', 'rings')

      # The first ring is the outer boundary and tends to contain far more points than subsequent rings.
      # All subsequent rings within this outer ring are bodies of water (essentially exclusion rings) and
      # can therefore be dismissed.
      # Boundary should be visualised to check how it should be used.
      # If algolia searches by polygon are slow, these boundaries could be downsampled significantly.
      points = []
      geometry_rings[0].each do |point|
        # API returns coords in an unconventional lng,lat order
        # Coordinates rounded as they are stored as double precision floats which have a precision of
        # 15 decimal digits. All UK coordinates only have a maxium of 2 digits before decimal point.
        points.push(*point.reverse.map { |coord| coord.round(13) })
      end

      LocationPolygon.find_or_create_by(name: region_name, location_type: location_type.to_s)
                     .update(boundary: points)
    end
  end

  private

  def location_categories_include?(region_name)
    location_type == :regions && DOWNCASE_REGIONS.include?(region_name) ||
      location_type == :counties && DOWNCASE_COUNTIES.include?(region_name) ||
      location_type == :london_boroughs && DOWNCASE_BOROUGHS.include?(region_name) ||
      location_type == :cities && DOWNCASE_CITIES.include?(region_name)
  end
end
