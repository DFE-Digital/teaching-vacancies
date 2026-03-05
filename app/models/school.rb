class School < Organisation
  has_many :school_group_memberships, dependent: :destroy
  has_many :school_groups, through: :school_group_memberships

  scope :not_excluded, -> { where.not(detailed_school_type: EXCLUDED_DETAILED_SCHOOL_TYPES) }

  validates :urn, uniqueness: true

  EXCLUDED_DETAILED_SCHOOL_TYPES = [
    "Further education",
    "Other independent school",
    "Online provider",
    "British schools overseas",
    "Institution funded by other government department",
    "Miscellaneous",
    "Offshore schools",
    "Service children’s education",
    "Special post 16 institution",
    "Other independent special school",
    "Higher education institutions",
    "Welsh establishment",
  ].freeze

  READABLE_PHASE_MAPPINGS = {
    not_applicable: nil,
    nursery: "nursery",
    primary: "primary",
    middle_deemed_primary: "primary",
    middle_deemed_secondary: "secondary",
    secondary: "secondary",
    sixth_form_or_college: "sixth_form_or_college",
    through: "through",
  }.freeze

  PHASE_TO_KEY_STAGES_MAPPINGS = {
    nursery: %i[early_years],
    primary: %i[early_years ks1 ks2],
    middle_deemed_primary: %i[ks1 ks2 ks3 ks4 ks5],
    middle_deemed_secondary: %i[ks1 ks2 ks3 ks4 ks5],
    secondary: %i[ks3 ks4 ks5],
    sixth_form_or_college: %i[ks5],
    through: %i[early_years ks1 ks2 ks3 ks4 ks5],
  }.freeze

  def religious_character
    return if !respond_to?(:gias_data) || gias_data.nil?
    return if ["None", "Does not apply"].include?(gias_data["ReligiousCharacter (name)"])

    gias_data["ReligiousCharacter (name)"]
  end

  def live_group_vacancies
    if part_of_a_trust?
      org_ids = [trust.id] + trust.schools.pluck(:id)
      PublishedVacancy.joins(:organisation_vacancies)
            .where(organisation_vacancies: { organisation_id: org_ids })
            .merge(PublishedVacancy.live)
            .distinct
    else
      PublishedVacancy.none
    end
  end

  def faith_school?
    religious_character.present?
  end

  def catholic_school?
    religious_character&.include?("Catholic") || false
  end

  def school_type
    read_attribute(:school_type).singularize
  end

  def key_stages
    return if phase == "not_applicable"

    PHASE_TO_KEY_STAGES_MAPPINGS[phase.to_sym]
  end

  def trust
    school_groups&.find(&:trust?)
  end

  def part_of_a_trust?
    trust.present?
  end

  def all_organisations
    [self]
  end

  def all_organisation_ids
    [id]
  end

  def ats_interstitial_variant
    if catholic_school?
      "catholic"
    elsif faith_school?
      "other_faith"
    else
      "non_faith"
    end
  end
end
