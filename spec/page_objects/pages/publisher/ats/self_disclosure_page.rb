module PageObjects
  module Pages
    module Publisher
      module Ats
        class SelfDisclosurePage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/{job_application_id}/self_disclosure"

          element :status, "#main-content .govuk-tag"
          element :button, ".govuk-grid-column-two-thirds .govuk-button"
          element :goto_references_and_declaration_form, "a.govuk-link:nth-child(7)"
          element :banner_title, "#govuk-notification-banner-title"

          section :personal_details, Sections::SelfDisclosure::PersonalDetailsSection, ".personal-details"
          section :criminal_details, Sections::SelfDisclosure::FormSection, ".criminal-record-declaration"
          section :conduct_details, Sections::SelfDisclosure::FormSection, ".conduct-declaration"
          section :confirmation_details, Sections::SelfDisclosure::FormSection, ".confirmation-declaration"

          section :communication_history, Sections::SelfDisclosure::CommunicationHistorySection, ".timeline-component"
        end
      end
    end
  end
end
