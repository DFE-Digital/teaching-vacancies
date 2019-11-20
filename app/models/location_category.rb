class LocationCategory < ApplicationRecord
  has_many :school_location_categories
  has_many :schools, through: :school_location_categories
end
