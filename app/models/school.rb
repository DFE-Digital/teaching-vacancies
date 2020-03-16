require 'breasal'
class School < ApplicationRecord
  include Auditor::Model

  belongs_to :school_type, optional: false
  belongs_to :detailed_school_type, optional: true
  belongs_to :region

  has_many :vacancies

  validates :urn, uniqueness: true

  delegate :name, to: :region, prefix: true

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

  alias_attribute :data, :gias_data

  def easting=(easting)
    self[:easting] = easting
    set_geolocation_from_easting_and_northing
  end

  def northing=(northing)
    self[:northing] = northing
    set_geolocation_from_easting_and_northing
  end

  def has_religious_character?
    return false if !self.respond_to?(:gias_data) || self.gias_data == nil
    ['None', 'Does not apply', nil].exclude?(self.gias_data['religious_character'])
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
