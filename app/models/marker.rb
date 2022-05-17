class Marker < ApplicationRecord
  belongs_to :vacancy
  belongs_to :organisation

  scope :search_by_location, MarkerLocationQuery
  scope :search_within_area, ->(area) { where("ST_Intersects(?, geopoint)", area.to_s) }
end
