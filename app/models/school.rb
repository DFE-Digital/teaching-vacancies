class School < Organisation
  has_many :school_group_memberships
  has_many :school_groups, through: :school_group_memberships

  scope :not_universities, (-> { where("gias_data->>'TypeOfEstablishment (code)' != ?", "29") })

  validates :urn, uniqueness: true

  enum phase: {
    not_applicable: 0,
    nursery: 1,
    primary: 2,
    middle_deemed_primary: 3,
    secondary: 4,
    middle_deemed_secondary: 5,
    sixth_form_or_college: 6,
    through: 7,
  }

  READABLE_PHASE_MAPPINGS = {
    not_applicable: nil,
    nursery: "nursery",
    primary: "primary",
    middle_deemed_primary: "middle",
    middle_deemed_secondary: "middle",
    secondary: "secondary",
    sixth_form_or_college: "sixth_form_or_college",
    through: "through",
  }.freeze

  def readable_phase
    READABLE_PHASE_MAPPINGS[phase.to_sym]
  end

  def religious_character
    return if !respond_to?(:gias_data) || gias_data.nil?
    return if ["None", "Does not apply"].include?(gias_data["ReligiousCharacter (name)"])

    gias_data["ReligiousCharacter (name)"]
  end

  def school_type
    read_attribute(:school_type).singularize
  end
end
