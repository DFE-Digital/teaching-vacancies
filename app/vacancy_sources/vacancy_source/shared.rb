module VacancySource::Shared
  def vacancy_listed_at_excluded_school_type?(schools)
    return false if schools.none?

    (schools.map(&:detailed_school_type) & School::EXCLUDED_DETAILED_SCHOOL_TYPES).present?
  end
end
