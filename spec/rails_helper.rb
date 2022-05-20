require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "axe-rspec"
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
Geocoder::DEFAULT_STUB_COORDINATES = [51.67014192630465, -1.2809649516211556].freeze
Geocoder::DEFAULT_LOCATION = "TE5 T1NG".freeze

Capybara.register_driver :chrome_headless do |app|
  capabilities = ::Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions" => { args: %w[no-sandbox headless disable-gpu window-size=1400,1400] },
  )

  if ENV["SELENIUM_HUB_URL"]
    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: ENV.fetch("SELENIUM_HUB_URL", nil),
      capabilities: capabilities,
    )
  else
    Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: capabilities)
  end
end
Capybara.javascript_driver = :chrome_headless
Capybara.server = :puma, { Silent: true, Threads: "0:1" }

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/components/shared_examples/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/page_objects/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

user_agents ||= YAML.load_file(Browser.root.join("test/ua.yml")).freeze
USER_AGENTS = user_agents

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.use_transactional_fixtures = true

  config.before do
    ActiveJob::Base.queue_adapter = :test

    allow(Google::Cloud::Bigquery).to receive(:new).and_return(
      double("BigQuery", dataset: double("BigQuery dataset", table: double.as_null_object)),
    )
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

  config.before(:each, type: :system, js: true) do
    driven_by :chrome_headless
  end

  config.before(:each, type: :system, accessibility: true) do
    driven_by :chrome_headless
  end

  config.before(:each, geocode: true) do
    allow(Rails.application.config).to receive(:geocoder_lookup).and_return(:default)
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

  config.include AccessibilityHelpers, type: :system
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
  config.include DistanceHelper
  config.include FactoryBot::Syntax::Methods
  config.include JobseekerHelpers
  config.include MailerHelpers
  config.include OrganisationsHelper
  config.include VacanciesHelper
  config.include VacancyHelpers
  config.include ViewComponent::TestHelpers, type: :component
  config.include WithEnv
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_localhost = true
  config.ignore_hosts "ea-edubase-api-prod.azurewebsites.net", "selenium-chrome"
  config.ignore_hosts IPSocket.getaddress(Socket.gethostname) if ENV.fetch("DEVCONTAINER", nil) == "true"
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
