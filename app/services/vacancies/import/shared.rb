module Vacancies::Import
  module Shared
    def vacancy_listed_at_excluded_school_type?(schools)
      return false if schools.none?

      (schools.map(&:detailed_school_type) & School::EXCLUDED_DETAILED_SCHOOL_TYPES).present?
    end

    # Our system only imports MAT type trusts from GIAS DB.
    # If a feed provides a vacancy associated to a central trust that is not a MAT, no trust will be found in our DB
    # so no orgs/schools would be associated with the vacancy.
    def vacancy_listed_at_excluded_trust_type?(schools, trust_uid)
      schools.none? && trust_uid.present?
    end
  end
end
