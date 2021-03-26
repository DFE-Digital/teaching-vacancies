module PageObjects
  module Publishers
    module Vacancies
      module JobApplications
        class Show < SitePrism::Page
          set_url "/organisation/jobs/{job_id}/job_applications/{id}"

          section :banner, ".banner-component" do
            element :job_title, "h1.govuk-heading-xl"
            element :status, "strong.govuk-tag"
          end

          section :timeline, ".timeline-component" do
            elements :items, ".timeline-component__items"
          end

          element :actions, ".job-application-actions"
        end
      end
    end
  end
end
