# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        class PreInterviewChecksPage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/{job_application_id}/pre_interview_checks"

          elements :reference_links, ".govuk-table .govuk-link"

          element :timeline, ".timeline-component"
        end
      end
    end
  end
end
