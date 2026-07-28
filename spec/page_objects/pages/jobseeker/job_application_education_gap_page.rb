module PageObjects
  module Pages
    module Jobseeker
      class JobApplicationEducationGapPage < CommonPage
        set_url "/jobseekers/{vacancy_id}/job_application/new"

        element :btn_start_application, "#main-content form .govuk-button"
      end
    end
  end
end
