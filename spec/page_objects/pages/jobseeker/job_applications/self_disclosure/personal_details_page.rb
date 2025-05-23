# frozen_string_literal: true

require_relative "base_page"

module PageObjects
  module Pages
    module Jobseeker
      module JobApplications
        module SelfDisclosure
          class PersonalDetailPage < BasePage
            set_url "jobseekers/job_applications/{job_application_id}/self_disclosure/personal_details"

            %i[
              name
              previous_names
              address_line_1
              address_line_2
              city
              country
              postcode
              phone_number
            ].each do |field|
              element field, selector(:personal_details, field)
            end

            section :date_of_birth, DateField, ".govuk-date-input"

            # boolean fields
            %i[has_unspent_convictions has_spent_convictions].each do |field|
              elements field, selector(:personal_details, field), visible: :all
            end
          end
        end
      end
    end
  end
end
