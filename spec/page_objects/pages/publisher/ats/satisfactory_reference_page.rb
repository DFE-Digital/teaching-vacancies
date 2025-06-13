# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        class SatisfactoryReferencePage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/{job_application_id}/reference_requests/{reference_request_id}/reference_received"

          element :yes, "label[for='publishers-vacancies-job-applications-mark-reference-as-received-form-reference-satisfactory-true-field']"
          element :no, "label[for='publishers-vacancies-job-applications-mark-reference-as-received-form-reference-satisfactory-false-field']"

          element :submit_button, "main form button[type='submit']"
        end
      end
    end
  end
end
