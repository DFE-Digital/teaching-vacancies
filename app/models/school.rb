class School < Organisation
  has_many :school_group_memberships, dependent: :destroy
  has_many :school_groups, through: :school_group_memberships

  scope :not_excluded, -> { where.not(detailed_school_type: OUT_OF_SCOPE_DETAILED_SCHOOL_TYPES) }

  validates :urn, uniqueness: true

  ACADEMY_TYPE = "Academies".freeze
  LA_SCHOOL_TYPE = "Local authority maintained schools".freeze
  FREE_SCHOOL_TYPE = "Free Schools".freeze
  INDEPENDENT_SCHOOL_TYPE = "Independent schools".freeze
  COLLEGE_SCHOOL_TYPE = "Colleges".freeze
  ONLINE_SCHOOL_TYPE = "Online provider".freeze
  OTHER_SCHOOL_TYPE = "Other types".freeze
  SPECIAL_SCHOOL_TYPE = "Special schools".freeze
  WELSH_SCHOOL_TYPE = "Welsh schools".freeze
  UNIVERSITY_SCHOOL_TYPE = "Universities".freeze

  FE_DETAILED_SCHOOL_TYPE = "Further education".freeze
  VALID_SCHOOL_TYPES = [LA_SCHOOL_TYPE,
                        INDEPENDENT_SCHOOL_TYPE,
                        SPECIAL_SCHOOL_TYPE,
                        UNIVERSITY_SCHOOL_TYPE,
                        ACADEMY_TYPE,
                        FREE_SCHOOL_TYPE,
                        WELSH_SCHOOL_TYPE,
                        OTHER_SCHOOL_TYPE,
                        COLLEGE_SCHOOL_TYPE,
                        ONLINE_SCHOOL_TYPE].freeze
  EXCLUDED_SCHOOL_TYPES = [UNIVERSITY_SCHOOL_TYPE, WELSH_SCHOOL_TYPE, ONLINE_SCHOOL_TYPE].freeze
  CLOSED_ESTABLISHMENT_STATUSES = %w[Closed].freeze
  OPEN_ESTABLISHMENT_STATUSES = ["Open", "Open, but proposed to close", "Proposed to open"].freeze

  # This is direct from GIAS
  validates :school_type, inclusion: { in: VALID_SCHOOL_TYPES, allow_nil: false }
  validates :detailed_school_type, presence: true
  validates :establishment_status, inclusion: { in: CLOSED_ESTABLISHMENT_STATUSES + OPEN_ESTABLISHMENT_STATUSES, allow_nil: false }

  CHRISTIAN_RELIGIOUS_TYPES = ["Anglican",
                               "United Reformed Church",
                               "Christian",
                               "Greek Orthodox",
                               "Anglican/Evangelical",
                               "Anglican/Church of England",
                               "Christian/Evangelical",
                               "Christian/Methodist",
                               "Christian/non-denominational",
                               "Protestant/Evangelical",
                               "Methodist/Church of England",
                               "Protestant",
                               "Reformed Baptist",
                               "Christian Science",
                               "Church of England",
                               "Plymouth Brethren Christian Church",
                               "Church of England/Methodist/United Reform Church/Baptist",
                               "Moravian", # Protestant Christian church movement
                               "Quaker",
                               "Methodist",
                               "Free Church",
                               "Church of England/Free Church",
                               "Church of England/Evangelical",
                               "Church of England/United Reformed Church",
                               "Anglican/Christian",
                               "Inter- / non- denominational",
                               "Seventh Day Adventist",
                               "Church of England/Christian",
                               "Church of England/Methodist",
                               "Congregational Church"].freeze

  CATHOLIC_RELIGIOUS_TYPES = ["Roman Catholic",
                              "Catholic",
                              "Roman Catholic/Anglican",
                              "Roman Catholic/Church of England",
                              "Church of England/Roman Catholic"].freeze

  OTHER_RELIGIOUS_TYPES = [
    "Jewish",
    "Orthodox Jewish",
    "Charadi Jewish",
    "Islam",
    "Muslim",
    "Sunni Deobandi",
    "Buddhist",
    "Sikh",
    "Hindu",
    "Multi-faith",
  ].freeze

  validates :religious_character, inclusion: {
    in: NON_FAITH_RELIGIOUS_CHARACTER_TYPES + CHRISTIAN_RELIGIOUS_TYPES + CATHOLIC_RELIGIOUS_TYPES + OTHER_RELIGIOUS_TYPES,
    allow_nil: false,
  }

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
    NON_FAITH_RELIGIOUS_CHARACTER_TYPES.exclude? religious_character
  end

  def catholic_school?
    religious_character.in? CATHOLIC_RELIGIOUS_TYPES
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
