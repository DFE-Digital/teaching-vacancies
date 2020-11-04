require "breasal"

class School < Organisation
  include Auditor::Model

  has_many :school_group_memberships
  has_many :school_groups, through: :school_group_memberships

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

  READABLE_PHASE_MAPPINGS = {
    not_applicable: [],
    nursery: %w[primary],
    primary: %w[primary],
    middle_deemed_primary: %w[middle],
    middle_deemed_secondary: %w[middle],
    secondary: %w[secondary],
    sixteen_plus: %w[16-19],
    all_through: %w[primary secondary 16-19],
  }.freeze

  def easting=(easting)
    self[:easting] = easting
    set_geolocation_from_easting_and_northing
  end

  def northing=(northing)
    self[:northing] = northing
    set_geolocation_from_easting_and_northing
  end

  def religious_character
    return if !respond_to?(:gias_data) || gias_data.nil?
    return if ["None", "Does not apply"].include?(gias_data["ReligiousCharacter (name)"])

    gias_data["ReligiousCharacter (name)"]
  end

private

  def set_geolocation_from_easting_and_northing
    if easting && northing
      wgs84 = Breasal::EastingNorthing.new(
        easting: easting.to_i,
        northing: northing.to_i,
        type: :gb,
      ).to_wgs84

      geolocation = [wgs84[:latitude], wgs84[:longitude]]
    end

    self.geolocation = geolocation
  end
end
