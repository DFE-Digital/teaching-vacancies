require "active_support"
require "active_support/core_ext"
require "capybara/rspec"
require "i18n_helper"
require "yaml"

CLOUD_DOMAIN = "test.teacherservices.cloud".freeze

RSpec.describe "Page availability", js: true, smoke_test: true do
  after do |example|
    # Print page on failure to help triage failures
    puts page.html if example.exception
  end

  context "Jobseeker visits vacancy page" do
    let(:smoke_test_auth) do
      # User/Pass defined on Github Env secrets (https://github.com/DFE-Digital/teaching-vacancies/settings/environments/)
      # They need to match the ones defined in AWS Parameter Store.
      http_basic_user = ENV.fetch("HTTP_BASIC_USER", "")
      http_basic_password = ENV.fetch("HTTP_BASIC_PASSWORD", "")
      return unless http_basic_password.present?

      "#{http_basic_user}:#{http_basic_password}@"
    end
    let(:smoke_test_domain) do
      aks_environment = ENV.fetch("AKS_ENVIRONMENT")
      begin
        YAML.load_file("#{__dir__}/../../terraform/workspace-variables/#{aks_environment}_app_env.yml")["DOMAIN"]
      rescue Errno::ENOENT
        "teaching-vacancies-#{aks_environment}.#{CLOUD_DOMAIN}"
      end
    end
    let(:page) { Capybara::Session.new(:selenium_chrome_headless) }
    let(:base_url) { "https://#{smoke_test_auth}#{smoke_test_domain}" }

    it "ensures users can search and view a job vacancy page" do
      page.visit "#{base_url}/404" # you need to be on the domain to set the cookie
      expect(page).to have_content("Page not found.")

      page.driver.browser.manage.add_cookie(name: "smoke_test", value: "1", domain: smoke_test_domain)
      page.driver.browser.manage.add_cookie(name: "consented-to-cookies", value: "no", domain: smoke_test_domain)

      page.visit "#{base_url}/"
      expect(page).to have_content(I18n.t("nav.create_a_job_alert"))

      page.visit "#{base_url}/jobs?keyword=Maths"

      expect(page).to have_css("h1", text: "Jobs")
      if page.has_css?(".search-results")
        expect(page).to have_content(I18n.t("subscriptions.link.text"))
      else
        expect(page).to have_content(I18n.t("subscriptions.link.no_search_results.link"))
      end

      if page.has_css?(".view-vacancy-link")
        page.first(".view-vacancy-link").click
        expect(page).to have_content(I18n.t("vacancies.show.job_details"))
        expect(page.current_url).to include("#{base_url}/jobs/")
      end
    end
  end
end
