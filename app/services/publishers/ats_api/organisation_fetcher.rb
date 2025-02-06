module Publishers
  module AtsApi
    module OrganisationFetcher
      InvalidOrganisationError = Class.new(StandardError)

      def fetch_organisations(school_params)
        return [] unless school_params

        trust = find_trust(school_params[:trust_uid])
        schools = find_schools(trust, school_params[:school_urns])

        validate_organisations!(trust, schools, school_params[:school_urns])

        schools.presence&.to_a || [trust]
      end

      private

      def find_trust(trust_uid)
        SchoolGroup.trusts.find_by(uid: trust_uid) if trust_uid.present?
      end

      def find_schools(trust, school_urns)
        return if school_urns.blank?

        if trust
          trust.schools.where(urn: school_urns)
        else
          ::Organisation.where(urn: school_urns)
        end
      end

      def validate_organisations!(trust, schools, school_urns)
        if no_valid_organisations?(trust, schools, school_urns)
          raise InvalidOrganisationError, "No valid organisations found"
        end
      end

      def no_valid_organisations?(trust, schools, school_urns)
        (schools.blank? && trust.blank?) ||
          (trust.present? && school_urns.present? && schools.blank?)
      end
    end
  end
end
