class LocalAuthority < ApplicationRecord
  has_many :local_authority_regional_pay_band_areas
  has_many :regional_pay_band_areas, through: :local_authority_regional_pay_band_areas

  validates :name, :code, presence: true

  def default_regional_pay_band_area
    if regional_pay_band_areas.count == 1
      regional_pay_band_areas.first
    else
      regional_pay_band_areas.find_by(name: 'Rest of England')
    end
  end
end
