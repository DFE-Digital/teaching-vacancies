class LocationPolygon < ApplicationRecord
  scope :cities, -> { where(location_type: 'cities') }
  scope :counties, -> { where(location_type: 'counties') }
  scope :london_boroughs, -> { where(location_type: 'london_boroughs') }
  scope :regions, -> { where(location_type: 'regions') }

  def points
    # Converts the 1-dimensional boundary attribute to a list of
    # 2-element lists (coordinates)
    boundary.each_slice(2).to_a
  end
end
