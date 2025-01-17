module Publishers
  module AtsApi
    module OrganisationFetcher
      def fetch_organisations(school_params)
        return [] unless school_params

        trust_uid = school_params[:trust_uid]
        school_urns = school_params[:school_urns]

        # When having both trust and schools, only return the schools that are in the trust if any.
        # Otherwise, return the trust itself.
        multi_academy_trust = SchoolGroup.trusts.find_by(uid: trust_uid)
        schools = ::Organisation.where(urn: school_urns) if school_urns.present?

        return [] if multi_academy_trust.blank? && schools.blank?
        return schools.to_a if multi_academy_trust.blank?
        return Array(multi_academy_trust) if schools.blank?

        multi_academy_trust.schools.where(urn: school_urns).order(:created_at).to_a.presence || Array(multi_academy_trust)
      end
    end
  end
end
