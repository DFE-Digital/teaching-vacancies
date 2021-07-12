require "capybara/rspec"
require "i18n_helper"
require "yaml"

CLOUDAPPS_DOMAIN = "london.cloudapps.digital".freeze

RSpec.describe "Page availability", js: true, smoke_test: true do
  after do |example|
    # Print page on failure to help triage failures
    puts page.html if example.exception
  end

  context "Jobseeker visits vacancy page" do
    let(:smoke_test_domain) do
      paas_environment = ENV.fetch("PAAS_ENVIRONMENT")
      begin
        YAML.load_file("#{__dir__}/../../terraform/workspace-variables/#{paas_environment}_app_env.yml")["DOMAIN"]
      rescue Errno::ENOENT
        "teaching-vacancies-#{paas_environment}.#{CLOUDAPPS_DOMAIN}"
      end
    end
    let(:page) { Capybara::Session.new(:selenium_chrome_headless) }

    it "ensures users can search and view a job vacancy page" do
      page.visit "https://#{smoke_test_domain}/404" # you need to be on the domain to set the cookie

      page.driver.browser.manage.add_cookie(name: "smoke_test", value: "1", domain: smoke_test_domain)
      page.driver.browser.manage.add_cookie(name: "consented-to-cookies", value: "no", domain: smoke_test_domain)

      page.visit "https://#{smoke_test_domain}/"
      expect(page).to have_content(I18n.t("jobs.heading"))

      page.fill_in I18n.t("jobs.search.keyword"), with: "Maths"
      page.click_on I18n.t("buttons.search")

      if page.has_css?(".search-results__header-stats")
        expect(page).to have_content(I18n.t("subscriptions.link.text"))
      else
        expect(page).to have_content(I18n.t("subscriptions.link.no_search_results.link"))
      end

      if page.has_css?(".view-vacancy-link")
        page.first(".view-vacancy-link").click
        expect(page).to have_content(I18n.t("jobs.job_summary"))
        expect(page.current_url).to include("https://#{smoke_test_domain}/jobs/")
      end
    end
  end
end
