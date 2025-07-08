module PageObjects
  module Pages
    module Jobseeker
      class JobApplicationBannerSection < SitePrism::Section
        element :header, "h1"
        element :tag, ".status-tag"
        element :delete_btn, ".delete-application"
        element :withdraw_btn, ".withdraw-application"
        element :download_btn, ".print-application"
        element :view_link, ".view-listing-link"
      end

      class TimelineSection < SitePrism::Section
        elements :items, ".timeline-component__item"
      end

      class QuickLinksSection < SitePrism::Section
        elements :items, ".navigation-list-component__anchor a"
      end

      class JobApplicationReviewSection < SitePrism::Section
        element :header, ".govuk-summary-card__title"
        element :content, ".govuk-summary-card__content"
      end

      class JobApplicationPage < CommonPage
        set_url "/jobseekers/job_applications/{id}"

        section :banner, JobApplicationBannerSection, ".review-banner"
        section :quick_links, QuickLinksSection, ".navigation-list-component"
        section :timeline, TimelineSection, ".timeline-component"
        sections :review_sections, JobApplicationReviewSection, ".review-component__sections .govuk-summary-card"
      end
    end
  end
end
