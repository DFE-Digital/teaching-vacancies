# frozen_string_literal: true

module PageObjects
  module Pages
    module Jobseeker
      module JobApplications
        module SelfDisclosure
          class DateField < SitePrism::Section
            def self.selector(field)
              %(input[name="jobseekers_job_applications_self_disclosure_personal_details_form[#{field}]"])
            end

            element :day, selector("date_of_birth(3i)")
            element :month, selector("date_of_birth(2i)")
            element :year, selector("date_of_birth(1i)")
          end
        end
      end
    end
  end
end
