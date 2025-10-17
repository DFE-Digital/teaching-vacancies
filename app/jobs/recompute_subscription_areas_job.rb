class RecomputeSubscriptionAreasJob < ApplicationJob
  queue_as :default

  def perform
    invalid_locations = polygon_locations = 0
    unique_area_locations_pairs = unique_subscriptions_area_locations_radius_pairs

    # For each unique location, update all the subscriptions with that location with a single query
    unique_area_locations_pairs.each do |location, radius|
      radius_in_metres = Subscription.convert_miles_to_metres(radius)
      subs_scope = subscriptions_scope(radius, location)

      if (polygon = LocationPolygon.find_valid_for_location(location))
        subs_scope.update_all(area: polygon.buffered_geometry_area(radius_in_metres))
        polygon_locations += 1
      else
        invalid_locations += 1
      end
    end

    Rails.logger.info("RecomputeSubscriptionAreasJob completed. Total unique locations: #{unique_area_locations_pairs.size}. " \
                      "Polygons: #{polygon_locations}, Invalid: #{invalid_locations}.")
  end

  private

  # Get all unique normalized location/radius pairs for subscriptions with an area
  def unique_subscriptions_area_locations_radius_pairs
    Subscription
      .where.not(area: nil)
      .pluck(
        Arel.sql("DISTINCT LOWER(TRIM(search_criteria->>'location'))"),
        Arel.sql("COALESCE((search_criteria->>'radius')::integer, 10)"),
      )
  end

  # Subscriptions with area for given location and radius that need updating
  def subscriptions_scope(radius, location)
    Subscription.where.not(area: nil)
                .where("LOWER(TRIM(search_criteria->>'location')) = ?", location)
                .where("COALESCE((search_criteria->>'radius')::integer, 10) = ?", radius)
  end
end
