require_relative "base_page"

module PageObjects
  module Pages
    module Jobseeker
      module JobApplications
        module SelfDisclosure
          class ConductPage < BasePage
            set_url "jobseekers/job_applications/{job_application_id}/self_disclosure/conduct"

            # boolean fields
            %i[
              is_known_to_children_services
              has_been_dismissed
              has_been_disciplined
              has_been_disciplined_by_regulatory_body
            ].each do |field|
              elements field, selector(:conduct, field), visible: :all
            end
          end
        end
      end
    end
  end
end
