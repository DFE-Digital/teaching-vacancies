module Sections
  module Jobseeker
    class JobApplicationReviewSection < SitePrism::Section
      element :header, ".govuk-summary-card__title"
      element :content, ".govuk-summary-card__content"
    end
  end
end
