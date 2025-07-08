module PageObjects
  module Pages
    module Jobseeker
      class JobApplicationApplyPage < CommonPage
        set_url "/jobseekers/job_applications/{id}/apply"

        section :banner, Sections::Jobseeker::JobApplicationBannerSection, ".review-banner"
        sections :tasks, Sections::Jobseeker::JobApplicationTaskSection, ".govuk-task-list__item"
      end
    end
  end
end
