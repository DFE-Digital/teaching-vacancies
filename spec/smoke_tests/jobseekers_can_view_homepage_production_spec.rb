require "capybara/rspec"
require "i18n_helper"

RSpec.describe "Page availability", js: true, smoke_test: true do
  context "Jobseeker visits vacancy page" do
    it "should ensure users can search and view a job vacancy page" do
      page = Capybara::Session.new(:selenium_chrome_headless)

      page.visit "https://teaching-vacancies.service.gov.uk/404" # you need to be on the domain to set the cookie

      page.driver.browser.manage.add_cookie(name: "smoke_test", value: "1", domain: "teaching-vacancies.service.gov.uk")

      page.visit "https://teaching-vacancies.service.gov.uk/"
      expect(page).to have_content(I18n.t("jobs.heading"))

      page.fill_in I18n.t("jobs.filters.keyword"), with: "Maths"
      page.click_on I18n.t("buttons.search")

      expect(page).to have_content(I18n.t("subscriptions.link.text"))

      vacancy_page = page.first(".view-vacancy-link")
      unless vacancy_page.nil?
        vacancy_page.click
        expect(page).to have_content(I18n.t("jobs.job_summary"))
        expect(page.current_url).to include("https://teaching-vacancies.service.gov.uk/jobs/")
      end
    end
  end
end
