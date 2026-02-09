require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "dfe/analytics/testing"
require "factory_bot_rails"
require "paper_trail/frameworks/rspec"
require "rack_session_access/capybara"
require "sidekiq/testing"
require "view_component/test_helpers"
require "webmock/rspec"
require "axe-rspec"

Sidekiq::Testing.fake!

# Stub Geocoder HTTP requests in specs
Geocoder::DEFAULT_STUB_COORDINATES = [51.1789, -1.8262].freeze
Geocoder::DEFAULT_LOCATION = "TE5 T1NG".freeze

# https://stackoverflow.com/questions/1368163/is-there-a-standard-domain-for-testing-throwaway-email
TEST_EMAIL_DOMAIN = "contoso.com".freeze

Capybara.server = :puma, { Silent: true, Threads: "0:1" }

require "capybara/cuprite"
Capybara.register_driver(:cuprite_headless) do |app|
  # The extra browser_options are required to run Cuprite within a devcontainer
  Capybara::Cuprite::Driver.new(app,
                                headless: true,
                                process_timeout: 30,
                                window_size: [1400, 1400],
                                browser_options: {
                                  "no-sandbox": nil,
                                  "disable-gpu": nil,
                                  "window-size": "1400,1400",
                                  headless: "new",
                                  "ozone-platform": "none",
                                })
end

Capybara.register_driver :chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox headless disable-gpu window-size=1400,1400])

  if ENV["SELENIUM_HUB_URL"]
    Capybara::Selenium::Driver.new(app, browser: :remote, url: ENV.fetch("SELENIUM_HUB_URL", nil), options:)
  else
    Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
  end
end

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox disable-gpu window-size=1400,1800])

  if ENV["SELENIUM_HUB_URL"]
    Capybara::Selenium::Driver.new(app, browser: :remote, url: ENV.fetch("SELENIUM_HUB_URL", nil), options:)
  else
    Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
  end
end

Capybara.register_driver(:cuprite_full) do |app|
  Capybara::Cuprite::Driver.new(app, headless: false, process_timeout: 45, window_size: [1400, 1800])
end
Capybara.javascript_driver = :cuprite_headless
Capybara.server = :puma, { Silent: true, Threads: "0:1" }

Capybara.configure do |config|
  # Allow us to use the `choose(label_text)` method in browser tests
  # even when the radio button element attached to the label is hidden
  # (as it is using the standard govuk radio element)
  config.automatic_label_click = true
end

Rails.root.glob("spec/support/**/*.rb").each { |f| require f }
Rails.root.glob("spec/components/shared_examples/**/*.rb").each { |f| require f }
Rails.root.glob("spec/page_objects/sections/**/*.rb").each { |f| require f }
Rails.root.glob("spec/page_objects/**/*.rb").each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.use_transactional_fixtures = true

  config.before do
    allow(Google::Cloud::Bigquery).to receive(:new).and_return(
      double("BigQuery", dataset: double("BigQuery dataset", table: double.as_null_object)),
    )

    stub_request(:get, %r{maps.googleapis.com/maps/api/place/autocomplete}).to_return(status: 200, body: '{"predictions": []}', headers: {})
  end

  config.before do |example|
    unless example.metadata.fetch(:geocode, false)
      allow(Geocoder).to receive(:search).and_raise
      allow_any_instance_of(Geocoding).to receive(:coordinates).and_return(Geocoder::DEFAULT_STUB_COORDINATES)
    end
  end

  config.around(:each, :dfe_analytics) do |example|
    ENV["ENABLE_DFE_ANALYTICS"] = "true"
    example.run
  ensure
    ENV.delete "ENABLE_DFE_ANALYTICS"
  end

  config.around(:each, :perform_enqueued) do |example|
    perform_enqueued_jobs do
      example.run
    end
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
    Capybara.default_host = "http://#{ENV.fetch('DOMAIN', 'localhost:3000')}"

    if ENV["SELENIUM_HUB_URL"]
      Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}:3000"
      Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
      Capybara.server_port = 3000
    end
  end

  config.before(:each, recaptcha: true) do
    recaptcha_reply = instance_double(Recaptcha::Reply, score: 0.9, success?: true)
    allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:recaptcha_reply).and_return(recaptcha_reply)
  end

  # allow developers to see JS backed tests by default
  config.before(:each, type: :system, js: true) do
    # In CI or devcontainers (without X11), use headless mode
    if ENV.key?("CI") || ENV["DEVCONTAINER"] == "true"
      driven_by :cuprite_headless
    else
      driven_by :cuprite_full
    end
  end

  #  Neither Cuprite nor playwright are supported by axe-rspec
  # https://github.com/dequelabs/axe-core-gems/issues/418
  config.before(:each, type: :system, a11y: true) do
    # In CI or devcontainers (without X11), use headless mode
    if ENV.key?("CI") || ENV["DEVCONTAINER"] == "true"
      driven_by :chrome_headless
    else
      driven_by :chrome
    end
  end

  # view specs idiom is allow(view).to receive_messages(x)
  # for controller methods. This seems like a good way to ensure this
  # as view specs should not use test doubles for any other purpose
  config.around(:each, type: :view) do |example|
    without_partial_double_verification do
      example.run
    end
  end

  config.before do
    allow(DisableEmailNotifications).to receive(:enabled?).and_return(false)
    allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false)
    allow(DisableIntegrations).to receive(:enabled?).and_return(false)
  end

  config.before(:each, disable_email_notifications: true) do
    allow(DisableEmailNotifications).to receive(:enabled?).and_return(true)
  end

  config.before(:each, disable_expensive_jobs: true) do
    allow(DisableExpensiveJobs).to receive(:enabled?).and_return(true)
  end

  config.before(:each, disable_integrations: true) do
    allow(DisableIntegrations).to receive(:enabled?).and_return(true)
  end

  config.around(:each, :with_csrf_protection) do |example|
    orig = ActionController::Base.allow_forgery_protection

    begin
      ActionController::Base.allow_forgery_protection = true
      example.run
    ensure
      ActionController::Base.allow_forgery_protection = orig
    end
  end

  config.around(:each, zendesk: true) do |example|
    with_env("ZENDESK_API_KEY" => SecureRandom.uuid) do
      example.run
    end
  end

  config.include ActionView::Helpers::NumberHelper
  config.include ActionView::Helpers::TextHelper
  config.include ActiveJob::TestHelper, type: :job
  config.include ActiveSupport::Testing::Assertions # required for ActiveJob::TestHelper#perform_enqueued_jobs
  config.include ActiveSupport::Testing::TimeHelpers
  config.include ApplicationHelpers
  config.include AuthHelpers
  config.include CapybaraHelper, type: :system
  config.include DatesHelper
  config.include Devise::Controllers::UrlHelpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include DistanceHelper
  config.include FactoryBot::Syntax::Methods
  config.include FileUploadHelpers
  config.include JobseekerHelpers
  config.include MailerHelpers
  config.include OrganisationsHelper
  config.include OrganisationHelpers
  config.include VacanciesHelper
  config.include VacancyHelpers
  config.include ViewComponent::TestHelpers, type: :component
  config.include WithEnv
  config.include PageObjects::Pages::Application
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_localhost = true
  config.ignore_hosts "ea-edubase-api-prod.azurewebsites.net", "selenium-chrome"
  config.ignore_hosts IPSocket.getaddress(Socket.gethostname) if ENV.fetch("DEVCONTAINER", nil) == "true"

  # defaults to method and URI
  config.default_cassette_options = {
    match_requests_on: %i[
      method
      uri_without_key_parameter
    ],
  }

  # we redact the 'key' parameter on map searches, so we need to exclude it from matches too.
  # as it defaults to matching the uri (which includes the query params)
  config.register_request_matcher :uri_without_key_parameter do |r1, r2|
    if r1.parsed_uri.host == "maps.googleapis.com"
      r1.parsed_uri.host == r2.parsed_uri.host &&
        r1.parsed_uri.scheme == r2.parsed_uri.scheme &&
        r1.parsed_uri.port == r2.parsed_uri.port &&
        r1.parsed_uri.path == r2.parsed_uri.path &&
        URI::QueryParams.parse(r1.parsed_uri.query).except("key") == URI::QueryParams.parse(r2.parsed_uri.query).except("key")
    else
      r1.uri == r2.uri
    end
  end

  config.filter_sensitive_data("<GOOGLE_LOCATION_SEARCH_API_KEY>") do |interaction|
    if interaction.request.parsed_uri.host == "maps.googleapis.com"
      URI::QueryParams.parse(interaction.request.parsed_uri.query)["key"]
    end
  end

  config.filter_sensitive_data("<TOKEN>") do |interaction|
    if interaction.request.uri == "https://becomingateacher.zendesk.com/api/v2/uploads"
      content_type = interaction.response.headers["Content-Type"]&.first
      if content_type.nil? || content_type.starts_with?("application/json")
        body = JSON.parse(interaction.response.body)
        body.is_a?(Hash) && body["upload"]["token"]
      end
    end
  end

  config.filter_sensitive_data("<BASIC_AUTH>") do |interaction|
    interaction.request.headers["Authorization"]&.first
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

def saop
  save_and_open_page # rubocop:disable Lint/Debugger
end
