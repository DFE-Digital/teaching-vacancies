class RegionalPayBandArea < ApplicationRecord
  has_many :local_authority_regional_pay_band_areas
  has_many :local_authorities, through: :local_authority_regional_pay_band_areas
end
