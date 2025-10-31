module PageObjects
  module Pages
    module Publisher
      module Ats
        class SelfDisclosurePage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/{job_application_id}/self_disclosure"

          element :status, "#main-content .govuk-tag"
          element :button, ".govuk-grid-column-two-thirds .govuk-button"
          element :reminder_btn, '[name="reminder"]'
          # element :goto_references_and_self_disclosure_form, "a.govuk-link:nth-child(7)"
          element :goto_references_and_self_disclosure_form, "p.govuk-body > a.govuk-link"
          element :banner_title, "#govuk-notification-banner-title"

          section :personal_details, Sections::SelfDisclosure::PersonalDetailsSection, ".personal-details"
          section :criminal_details, Sections::SelfDisclosure::FormSection, ".criminal-record-self-disclosure"
          section :conduct_details, Sections::SelfDisclosure::FormSection, ".conduct-self-disclosure"
          section :confirmation_details, Sections::SelfDisclosure::FormSection, ".confirmation-self-disclosure"

          section :communication_history, Sections::SelfDisclosure::CommunicationHistorySection, ".timeline-component"
        end
      end
    end
  end
end
