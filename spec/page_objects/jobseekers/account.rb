module PageObjects
  module Jobseekers
    class Account < SitePrism::Page
      set_url "/jobseekers/account"

      section :dashboard_header, ".dashboard-component" do
        element :email, "h2.govuk-heading-m"
        section :nav, ".dashboard-component-navigation__list" do
          elements :links, ".dashboard-component-navigation__link"
        end
      end
    end
  end
end
