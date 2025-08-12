module PageObjects
  module Pages
    module Publisher
      module Ats
        class ReferenceAndSelfDisclosurePage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_application_batches/{batch_id}/references_and_self_disclosure/{step}"

          def self.collect_references(value)
            "#publishers-job-application-collect-references-form-collect-references-and-self-disclosure-#{value}-field"
          end

          def self.contact_applicant(value)
            "#publishers-job-application-references-contact-applicant-form-contact-applicants-#{value}-field"
          end

          element :collect_references_yes, collect_references(true), visible: false
          element :collect_references_no,  collect_references(false), visible: false

          element :contact_applicant_yes, contact_applicant(true), visible: false
          element :contact_applicant_no,  contact_applicant(false), visible: false

          element :btn_save, "#main-content form .govuk-button"

          def external_pre_checks
            collect_references_no.click
            btn_save.click
          end
        end
      end
    end
  end
end
