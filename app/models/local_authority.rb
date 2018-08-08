class LocalAuthority < ApplicationRecord
  has_many :local_authority_regional_pay_band_areas
  has_many :regional_pay_band_areas, through: :local_authority_regional_pay_band_areas

  validates :name, :code, presence: true
end
