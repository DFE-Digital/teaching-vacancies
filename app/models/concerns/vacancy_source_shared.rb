module VacancySourceShared
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

  def vacancy_listed_at_excluded_school_type?(schools)
    (schools.map(&:detailed_school_type) & EXCLUDED_DETAILED_SCHOOL_TYPES).present?
  end
end
