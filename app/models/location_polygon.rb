class LocationPolygon < ApplicationRecord
  scope :cities, -> { where(location_type: 'cities') }
  scope :counties, -> { where(location_type: 'counties') }
  scope :local_authorities, -> { where(location_type: 'local_authorities') }
  scope :regions, -> { where(location_type: 'regions') }
end
