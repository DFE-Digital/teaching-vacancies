class Marker < ApplicationRecord
  belongs_to :vacancy
  belongs_to :organisation

  self.ignored_columns += %i[geopoint]

  scope :search_by_location, MarkerLocationQuery
end
