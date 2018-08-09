require 'breasal'
class School < ApplicationRecord
  include Auditor::Model

  belongs_to :school_type
  belongs_to :detailed_school_type, optional: true
  belongs_to :region
  belongs_to :local_authority
  belongs_to :regional_pay_band_area, required: false
  has_many :pay_scales, through: :regional_pay_band_area

  has_many :vacancies

  validates :urn, uniqueness: true

  enum phase: {
    not_applicable: 0,
    nursery: 1,
    primary: 2,
    middle_deemed_primary: 3,
    secondary: 4,
    middle_deemed_secondary: 5,
    sixteen_plus: 6,
    all_through: 7,
  }

  def minimum_pay_scale_salary
    pay_scales.current.minimum(:salary).to_i
  end

  def easting=(easting)
    self[:easting] = easting
    set_geolocation_from_easting_and_northing
  end

  def northing=(northing)
    self[:northing] = northing
    set_geolocation_from_easting_and_northing
  end

  private

  def set_geolocation_from_easting_and_northing
    if easting && northing
      wgs84 = Breasal::EastingNorthing.new(
        easting: easting.to_i,
        northing: northing.to_i,
        type: :gb
      ).to_wgs84

      geolocation = [wgs84[:latitude], wgs84[:longitude]]
    end

    self.geolocation = geolocation
  end
end
