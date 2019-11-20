class SchoolLocationCategory < ApplicationRecord
  belongs_to :school
  belongs_to :location_category
end
