require "breasal"

class School < Organisation
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
    "16-19": 6,
    all_through: 7,
  }

  READABLE_PHASE_MAPPINGS = {
    not_applicable: [],
    nursery: %w[primary],
    primary: %w[primary],
    middle_deemed_primary: %w[middle],
    middle_deemed_secondary: %w[middle],
    secondary: %w[secondary],
    "16-19": %w[16-19],
    all_through: %w[primary middle secondary 16-19],
  }.freeze

  def religious_character
    return if !respond_to?(:gias_data) || gias_data.nil?
    return if ["None", "Does not apply"].include?(gias_data["ReligiousCharacter (name)"])

    gias_data["ReligiousCharacter (name)"]
  end
end
