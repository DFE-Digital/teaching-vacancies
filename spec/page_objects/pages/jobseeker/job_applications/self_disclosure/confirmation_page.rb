require_relative "base_page"

module PageObjects
  module Pages
    module Jobseeker
      module JobApplications
        module SelfDisclosure
          class ConfirmationPage < BasePage
            set_url "jobseekers/job_applications/{job_application_id}/self_disclosure/confirmation"

            def self.selector(field)
              %(input[name="jobseekers_job_applications_self_disclosure_confirmation_form[#{field}]"])
            end

            # boolean fields
            %i[
              agreed_for_processing
              agreed_for_criminal_record
              agreed_for_organisation_update
              agreed_for_information_sharing
            ].each do |field|
              elements field, selector(field), visible: :all
            end
          end
        end
      end
    end
  end
end
