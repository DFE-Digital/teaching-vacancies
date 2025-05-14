# frozen_string_literal: true

module PageObjects
  module Pages
    module Jobseeker
      module JobApplications
        module SelfDisclosure
          class PersonalDetailPage < CommonPage
            set_url "jobseekers/job_applications/{job_application_id}/self_disclosure/personal_details"

            element :name, "#jobseekers-job-applications-self-disclosure-personal-details-form-name-field"
            element :previous_name, "#jobseekers-job-applications-self-disclosure-personal-details-form-address-line-1-field"

            def submit_form
              click_on "Save and continue"
            end

            def fill_in_and_submit_form(model)
              self.class.mapped_items[:element].each do |elt|
                public_send(elt).set(model.public_send(elt))
              end

              submit_form
            end
          end
        end
      end
    end
  end
end
