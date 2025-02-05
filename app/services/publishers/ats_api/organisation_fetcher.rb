module Publishers
  module AtsApi
    module OrganisationFetcher
      InvalidOrganisationError = Class.new(StandardError)

      def fetch_organisations(school_params)
        return [] unless school_params

        trust = find_trust(school_params[:trust_uid])
        schools = find_schools(school_params[:school_urns])

        validate_organisations!(trust, schools, school_params[:school_urns])

        return schools.to_a if trust.blank?
        return [trust] if schools.blank?

        fetch_valid_schools(trust, school_params[:school_urns])
      end

      private

      def find_trust(trust_uid)
        SchoolGroup.trusts.find_by(uid: trust_uid) if trust_uid.present?
      end

      def find_schools(school_urns)
        ::Organisation.where(urn: school_urns) if school_urns.present?
      end

      def validate_organisations!(trust, schools, school_urns)
        if no_valid_organisations?(trust, schools, school_urns)
          raise InvalidOrganisationError, "No valid organisations found"
        end
      end

      def no_valid_organisations?(trust, schools, school_urns)
        (schools.blank? && trust.blank?) ||
          (trust.present? && school_urns.present? && invalid_trust_school_match?(trust, school_urns))
      end

      def invalid_trust_school_match?(trust, school_urns)
        trust.schools.where(urn: school_urns).blank?
      end

      def fetch_valid_schools(trust, school_urns)
        trust.schools.where(urn: school_urns).order(:created_at).presence || [trust]
      end
    end
  end
end
