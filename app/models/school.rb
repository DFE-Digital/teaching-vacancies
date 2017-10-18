class School < ApplicationRecord
  belongs_to :school_type, required: true
  belongs_to :region

  enum phase: %i[primary secondary]
end
