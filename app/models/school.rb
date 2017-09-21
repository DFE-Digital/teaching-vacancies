class School < ApplicationRecord
  belongs_to :school_type, required: true
  belongs_to :region

  enum phase: %i[primary secondary]

  def full_address
    [address, town, county, postcode].compact.join(', ')
  end
end
