require "page_objects/shared/review_section"

module PageObjects
  module Jobseekers
    module JobApplications
      class Show < SitePrism::Page
        set_url "/jobseekers/job_applications/{id}"

        sections :steps, PageObjects::Shared::ReviewSection, ".review-component"

        section :banner, ".banner-component" do
          element :job_title, "h1.govuk-heading-xl"
          element :status, "strong.govuk-tag"
        end

        section :timeline, ".timeline-component" do
          elements :items, ".timeline-component__items"
        end
      end
    end
  end
end
