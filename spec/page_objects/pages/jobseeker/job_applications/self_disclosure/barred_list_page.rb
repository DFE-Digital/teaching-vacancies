# frozen_string_literal: true

require_relative "base_page"

module PageObjects
  module Pages
    module Jobseeker
      module JobApplications
        module SelfDisclosure
          class BarredListPage < BasePage
            set_url "jobseekers/job_applications/{job_application_id}/self_disclosure/barred_list"

            # boolean fields
            %i[is_barred has_been_referred].each do |field|
              elements field, selector(:barred_list, field), visible: :all
            end
          end
        end
      end
    end
  end
end
