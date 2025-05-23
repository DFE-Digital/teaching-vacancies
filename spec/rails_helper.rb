require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "dfe/analytics/testing"
require "factory_bot_rails"
require "geocoder"
require "geocoding"
require "paper_trail/frameworks/rspec"
require "rack_session_access/capybara"
require "sidekiq/testing"
require "view_component/test_helpers"
require "webmock/rspec"

Sidekiq::Testing.fake!

# Stub Geocoder HTTP requests in specs
Geocoder::DEFAULT_STUB_COORDINATES = [51.1789, -1.8262].freeze
Geocoder::DEFAULT_LOCATION = "TE5 T1NG".freeze

# https://stackoverflow.com/questions/1368163/is-there-a-standard-domain-for-testing-throwaway-email
TEST_EMAIL_DOMAIN = "contoso.com".freeze

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
Capybara.javascript_driver = :chrome_headless
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
    ActiveJob::Base.queue_adapter = :test

    allow(Google::Cloud::Bigquery).to receive(:new).and_return(
      double("BigQuery", dataset: double("BigQuery dataset", table: double.as_null_object)),
    )

    mock_response = [double(country: "United Kingdom")]
    allow(Geocoder).to receive(:search).and_return(mock_response)
    stub_request(:get, %r{maps.googleapis.com/maps/api/place/autocomplete}).to_return(status: 200, body: '{"predictions": []}', headers: {})
  end

  config.before(:each, geocode: true) do
    allow(Geocoder).to receive(:search).and_call_original
    allow(Rails.application.config).to receive(:geocoder_lookup).and_return(:default)
  end

  config.around(:each, :dfe_analytics) do |example|
    ENV["ENABLE_DFE_ANALYTICS"] = "true"
    example.run
    ENV.delete "ENABLE_DFE_ANALYTICS"
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
    recaptcha_reply = double("recaptcha_reply")
    allow(recaptcha_reply).to receive(:dig).with("score").and_return(0.9)
    allow(recaptcha_reply).to receive(:[]).with("score").and_return(0.9)
    allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:recaptcha_reply).and_return(recaptcha_reply)
  end

  # allow developers to see JS backed tests by default
  config.before(:each, type: :system, js: true) do
    if ENV.key? "CI"
      driven_by :chrome_headless
    else
      driven_by :chrome
    end
  end

  config.before do
    allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false)
  end

  config.before(:each, disable_expensive_jobs: true) do
    allow(DisableExpensiveJobs).to receive(:enabled?).and_return(true)
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
