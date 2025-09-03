# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        class ReferenceRequestPage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/{job_application_id}/reference_requests/{reference_request_id}"

          element :use_tv_anyway_link, ".govuk-body a.govuk-link"

          elements :timeline_titles, ".timeline-component__key"
        end
      end
    end
  end
end
