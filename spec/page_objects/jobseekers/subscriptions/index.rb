require "page_objects/shared/card"

module PageObjects
  module Jobseekers
    module Subscriptions
      class Index < SitePrism::Page
        set_url "jobseekers/subscriptions"

        element :heading, "h1.govuk-heading-l"
        sections :cards, PageObjects::Shared::Card, ".card-component"
      end
    end
  end
end
