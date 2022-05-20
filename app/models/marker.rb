class Marker < ApplicationRecord
  belongs_to :vacancy
  belongs_to :organisation

  scope :search_by_location, MarkerLocationQuery
end
