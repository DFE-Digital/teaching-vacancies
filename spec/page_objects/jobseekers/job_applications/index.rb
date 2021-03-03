require "page_objects/shared/card"

module PageObjects
  module Jobseekers
    module JobApplications
      class Index < SitePrism::Page
        set_url "jobseekers/job_applications"

        element :heading, "h1.govuk-heading-l"
        sections :cards, PageObjects::Shared::Card, ".card-component"
      end
    end
  end
end
