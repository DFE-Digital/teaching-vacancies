module PageObjects
  module Jobseekers
    module JobApplications
      class New < SitePrism::Page
        set_url "jobseekers{/job_id}/job_application/new"

        element :caption, ".govuk-caption-l"
      end
    end
  end
end
