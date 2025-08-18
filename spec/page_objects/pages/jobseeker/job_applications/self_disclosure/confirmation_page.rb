require_relative "base_page"

module PageObjects
  module Pages
    module Jobseeker
      module JobApplications
        module SelfDisclosure
          class ConfirmationPage < BasePage
            set_url "jobseekers/job_applications/{job_application_id}/self_disclosure/confirmation"

            Jobseekers::JobApplications::SelfDisclosure::ConfirmationForm::FIELDS.each do |field|
              elements field, selector("confirmation", field)
            end
          end
        end
      end
    end
  end
end
