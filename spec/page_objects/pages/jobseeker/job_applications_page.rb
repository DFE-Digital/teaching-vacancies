module PageObjects
  module Pages
    module Jobseeker
      class JobApplicationsPage < CommonPage
        set_url "/jobseekers/job_applications"

        element :header, "h1"
        sections :job_applications, Sections::Jobseeker::JobApplicationSection, "#applications-results .card-component"

        def job_application(job_application_id)
          job_applications.detect { it.header["href"].include?(job_application_id) }
        end

        def click_on_job_application(job_application_id)
          job_application(job_application_id).header.click
        end
      end
    end
  end
end
