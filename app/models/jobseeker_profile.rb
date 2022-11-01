require "geocoding"

class JobseekerProfile < ApplicationRecord
  include DistanceHelper

  scope :search_by_organisation_inclusion_in_location_preference_area, JobseekerProfileLocationPreferenceQuery

  before_save :set_geolocation, if: -> { location_changed? || radius_changed? }

  private

  def set_geolocation
    normalised_location = location.strip.downcase

    if LocationPolygon.include?(normalised_location)
      location_polygon = radius.present? ? LocationPolygon.buffered(radius).with_name(normalised_location).area : LocationPolygon.with_name(normalised_location).area

      self.location_preference = location_polygon
    else
      geocoded_location = geocoded_location(normalised_location)

      self.location_preference = factory.point(*geocoded_location.reverse).buffer(convert_miles_to_metres(radius))
    end
  end

  def geocoded_location(location)
    Geocoding.new(location).coordinates
  end

  def factory
    @factory ||= RGeo::ActiveRecord::SpatialFactoryStore.instance.default
  end
end
