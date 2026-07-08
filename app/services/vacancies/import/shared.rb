module Vacancies::Import
  module Shared
    LEGACY_WORKING_PATTERNS = %w[flexible term_time job_share].freeze
    def vacancy_listed_at_excluded_school_type?(schools)
      return false if schools.none?

      (schools.map(&:detailed_school_type) & School::OUT_OF_SCOPE_DETAILED_SCHOOL_TYPES).present?
    end

    # Soft-deleted organisations and FE colleges must not publish vacancies through feed integrations.
    # Items whose URNs only match such organisations are skipped instead of falling back to their trust.
    def no_importable_organisations?(trust, school_urns, schools)
      (trust.blank? && schools.blank?) ||
        (school_urns.present? && schools.blank? && Organisation.exists?(urn: school_urns))
    end

    # Our system only imports MAT type trusts from GIAS DB.
    # If a feed provides a vacancy associated to a central trust that is not a MAT, no trust will be found in our DB
    # so no orgs/schools would be associated with the vacancy.
    def vacancy_listed_at_excluded_trust_type?(schools, trust_uid)
      schools.none? && trust_uid.present?
    end

    def map_middle_school_phase(phase)
      case phase
      when "middle_deemed_primary"
        %w[primary]
      when "middle_deemed_secondary"
        %w[secondary]
      else
        %w[primary secondary]
      end
    end
  end
end
