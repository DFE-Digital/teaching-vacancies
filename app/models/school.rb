class School < ApplicationRecord
  belongs_to :school_type, required: true
  belongs_to :region
end
