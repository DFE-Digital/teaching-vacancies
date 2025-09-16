module PageObjects
  module Pages
    module Jobseeker
      class JobApplicationPage < CommonPage
        set_url "/jobseekers/job_applications/{id}"

        section :banner, Sections::Jobseeker::JobApplicationBannerSection, ".review-banner"
        section :quick_links, Sections::QuickLinksSection, ".navigation-list-component"
        section :timeline, Sections::TimelineSection, ".timeline-component"
        sections :review_sections, Sections::Jobseeker::JobApplicationReviewSection, ".review-component__sections .govuk-summary-card"

        element :tag, ".status-tag"
      end
    end
  end
end
