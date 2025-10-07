class BackfillSubscriptionLocationJob < ApplicationJob
  queue_as :default

  def perform
    invalid_locations = polygon_locations = coordinate_locations = 0
    unique_locations_pairs = unique_subscriptions_locations_radius_pairs

    # For each unique location, update all the subscriptions with that location with a single query
    unique_locations_pairs.each do |location, radius|
      next if location.blank?

      radius ||= 10
      radius_in_metres = Subscription.convert_miles_to_metres(radius)
      subs_scope = subscriptions_scope(radius, location)

      if (polygon = valid_polygon_for_location(location))
        set_subscriptions_area(subs_scope, polygon, radius_in_metres)
        polygon_locations += 1
      elsif (coordinates = location_coordinates(location))
        set_subscriptions_geopoint(subs_scope, coordinates, radius_in_metres)
        coordinate_locations += 1
      else
        invalid_locations += 1
      end
    end

    Rails.logger.info("BackfillSubscriptionLocationJob completed. Total unique locations: #{unique_locations_pairs.size}. " \
                      "Polygons: #{polygon_locations}, Coordinates: #{coordinate_locations}, Invalid: #{invalid_locations}.")
  end

  private

  # Get all unique normalized location/radius pairs
  def unique_subscriptions_locations_radius_pairs
    Subscription
      .where(area: nil, geopoint: nil)
      .where("(search_criteria->>'location') IS NOT NULL AND TRIM(search_criteria->>'location') <> ''")
      .pluck(
        Arel.sql("DISTINCT LOWER(TRIM(search_criteria->>'location'))"),
        Arel.sql("COALESCE((search_criteria->>'radius')::integer, 10)"),
      )
  end

  # Subscriptions with given location and radius that need updating
  def subscriptions_scope(radius, location)
    Subscription.where(area: nil, geopoint: nil)
                .where("LOWER(TRIM(search_criteria->>'location')) = ?", location)
                .where("COALESCE((search_criteria->>'radius')::integer, 10) = ?", radius)
  end

  def valid_polygon_for_location(location)
    polygon = LocationPolygon.with_name(location)
    if polygon.present? && polygon.area.invalid_reason.nil?
      polygon
    end
  rescue RGeo::Error::InvalidGeometry
    nil
  end

  # Buffering is best done in a projected coordinate system (like 3857) for accuracy, as it buffers in metres instead of degrees).
  # After buffering, we transform to SRID: 4326 (lat/lon data) for storage and querying.
  def polygon_buffered_geom(polygon, radius_in_metres)
    LocationPolygon
      .where(id: polygon.id)
      .pick(Arel.sql("ST_Transform(ST_Buffer(ST_Transform(area::geometry, 3857), #{radius_in_metres}), 4326)"))
  end

  def location_coordinates(location)
    coordinates = Geocoding.new(location).coordinates
    coordinates if coordinates.present? && coordinates != Geocoding::COORDINATES_NO_MATCH
  end

  def set_subscriptions_area(subs_scope, polygon, radius_in_metres)
    subs_scope.update_all(
      radius_in_metres: radius_in_metres,
      area: polygon_buffered_geom(polygon, radius_in_metres),
      geopoint: nil,
    )
  end

  def set_subscriptions_geopoint(subs_scope, coordinates, radius_in_metres)
    point = RGeo::Cartesian.factory(srid: 4326).point(coordinates.second, coordinates.first)
    subs_scope.update_all(
      radius_in_metres: radius_in_metres,
      area: nil,
      geopoint: point,
    )
  end
end
