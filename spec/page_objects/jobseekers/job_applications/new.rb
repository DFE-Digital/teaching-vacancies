module PageObjects
  module Jobseekers
    module JobApplications
      class New < SitePrism::Page
        set_url "jobseekers{/job_id}/job_application/new"

        element :caption, ".govuk-caption-l"
        element :start_application, ".govuk-button--start"
      end
    end
  end
end
