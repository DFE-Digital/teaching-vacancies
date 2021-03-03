require "page_objects/shared/card"

module PageObjects
  module Jobseekers
    module SavedJobs
      class Index < SitePrism::Page
        set_url "jobseekers/saved_jobs"

        element :heading, "h1.govuk-heading-l"
        sections :cards, PageObjects::Shared::Card, ".card-component"
      end
    end
  end
end
