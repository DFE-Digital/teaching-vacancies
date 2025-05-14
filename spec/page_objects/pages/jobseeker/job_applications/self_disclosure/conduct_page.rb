module PageObjects
  module Pages
    module Jobseeker
      module JobApplications
        module SelfDisclosure
          class ConductPage < CommonPage
            set_url "jobseekers/job_applications/{job_application_id}/self_disclosure/conduct"

            element :name, "#jobseekers-job-applications-self-disclosure-personal-details-form-name-field"
            element :previous_name, "#jobseekers-job-applications-self-disclosure-personal-details-form-address-line-1-field"

            def submit_form
              click_on "Save and continue"
            end

            def fill_in_and_submit_form(self_disclosure)
              name.set("some name")
              previous_name.set("my prev name")

              submit_form
            end
          end
        end
      end
    end
  end
end
