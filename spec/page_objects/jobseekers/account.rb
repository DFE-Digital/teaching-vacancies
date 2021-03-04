module PageObjects
  module Jobseekers
    class Account < SitePrism::Page
      set_url "/jobseekers/account"

      section :dashboard_header, ".dashboard-component" do
        element :email, "h2.govuk-heading-m"
        section :nav, ".moj-primary-navigation__list" do
          elements :links, ".moj-primary-navigation__link"
        end
      end
    end
  end
end
