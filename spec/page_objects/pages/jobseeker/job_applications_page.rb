module PageObjects
  module Pages
    module Jobseeker
      class JobApplicationSection < SitePrism::Section
        element :header, ".card-component__header a"
        element :tag, ".card-component__action .govuk-tag"
      end

      class JobApplicationsPage < CommonPage
        set_url "/jobseekers/job_applications"

        element :header, "h1"
        sections :job_applications, JobApplicationSection, "#applications-results .card-component"
      end
    end
  end
end
