# frozen_string_literal: true

module PageObjects
  module Pages
    class CommonPage < SitePrism::Page
      element :notification_banner, ".govuk-notification-banner"

      elements :errors, "ul.govuk-list.govuk-error-summary__list a"
    end
  end
end
