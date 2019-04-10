require 'breasal'
class School < ApplicationRecord
  acts_as_mappable lat_column_name: :latitude,
                   lng_column_name: :longitude

  include Auditor::Model

  belongs_to :school_type, optional: false
  belongs_to :detailed_school_type, optional: true
  belongs_to :region

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
    self.latitude = wgs84[:latitude]
    self.longitude = wgs84[:longitude]
  end

  def wgs84
    return {} if invalid_coords?

    Breasal::EastingNorthing.new(
      easting: easting.to_i,
      northing: northing.to_i,
      type: :gb
    ).to_wgs84
  end

  def invalid_coords?
    easting.blank? || northing.blank?
  end
end
