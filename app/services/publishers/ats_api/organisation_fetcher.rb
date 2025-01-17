module Publishers
  module AtsApi
    module OrganisationFetcher
      def fetch_organisations(school_params)
        return [] unless school_params

        if school_params[:trust_uid].present?
          SchoolGroup.trusts.find_by(uid: school_params[:trust_uid]).schools&.where(urn: school_params[:school_urns]) || []
        else
          School.where(urn: school_params[:school_urns])
        end
      end
    end
  end
end
