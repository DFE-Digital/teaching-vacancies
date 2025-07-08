module PageObjects
  module Pages
    module Jobseeker
      class JobApplicationsPage < CommonPage
        set_url "/jobseekers/job_applications"

        element :header, "h1"
        sections :job_applications, Sections::Jobseeker::JobApplicationSection, "#applications-results .card-component"
      end
    end
  end
end
