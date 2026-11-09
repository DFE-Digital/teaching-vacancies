module Publishers
  module JobListing
    class JobLocationForm < JobListingForm
      attr_accessor :organisation_ids

      validates :organisation_ids, presence: true

      class << self
        def load_from_params(form_params, vacancy, current_publisher:)
          valid_org_ids = current_publisher.organisations.flat_map(&:all_organisation_ids)
          super(form_params.merge(organisation_ids: valid_org_ids & form_params[:organisation_ids]), vacancy, current_publisher: current_publisher)
        end

        def fields
          { organisation_ids: [] }
        end
      end

      def params_to_save
        organisations = ::Organisation.where(id: organisation_ids)
        location_params = { organisations: organisations }
        school_phases = organisations.schools.map(&:phase).uniq
        vacancy_phases  = school_phases.select { |phase| phase.in? Vacancy::SCHOOL_PHASES_MATCHING_VACANCY_PHASES }

        if vacancy_phases.any? || organisations.schools.all?(&:school_group?)
          location_params.merge(phases: vacancy_phases)
        else
          location_params
        end
      end
    end
  end
end
