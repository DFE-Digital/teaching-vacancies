require "simplecov"
SimpleCov.start

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "factory_bot_rails"
require "geocoder"
require "rack_session_access/capybara"
require "sidekiq/testing"
require "view_component/test_helpers"
require "webmock/rspec"
require "site_prism"
require "site_prism/all_there"

Sidekiq::Testing.fake!

# Stub Geocoder HTTP requests in specs
Geocoder::DEFAULT_STUB_COORDINATES = [51.67014192630465, -1.2809649516211556].freeze
Geocoder.configure(lookup: :test)
Geocoder::Lookup::Test.set_default_stub([{ coordinates: Geocoder::DEFAULT_STUB_COORDINATES }])

Capybara.server = :puma, { Silent: true, Threads: "0:1" }

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
Dir[Rails.root.join("spec/page_objects/**/*.rb")].sort.each { |f| require f }
Dir[Rails.root.join("lib/**/*.rb")].sort.each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

user_agents ||= YAML.load_file(Browser.root.join("test/ua.yml")).freeze
USER_AGENTS = user_agents

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.use_transactional_fixtures = true

  config.before(:each, :sitemap) do
    default_url_options[:host] = DOMAIN.to_s
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
    Capybara.default_host = "http://#{ENV.fetch('DOMAIN', 'localhost:3000')}"
  end

  config.before(:each, recaptcha: true) do
    recaptcha_reply = double("recaptcha_reply")
    allow(recaptcha_reply).to receive(:dig).with("score").and_return(0.9)
    allow(recaptcha_reply).to receive(:[]).with("score").and_return(0.9)
    allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:recaptcha_reply).and_return(recaptcha_reply)
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :headless_chrome
  end

  config.before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(false)
    allow(Redis).to receive(:new).and_return(MockRedis.new)
    ActiveJob::Base.queue_adapter = :test
  end

  config.include ActionView::Helpers::NumberHelper
  config.include ActionView::Helpers::TextHelper
  config.include ActiveSupport::Testing::Assertions # required for ActiveJob::TestHelper#perform_enqueued_jobs
  config.include ActiveSupport::Testing::TimeHelpers
  config.include ApplicationHelpers
  config.include AuthHelpers
  config.include CapybaraHelper, type: :system
  config.include DatesHelper
  config.include Devise::Controllers::UrlHelpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include DistanceHelper
  config.include FactoryBot::Syntax::Methods
  config.include MailerHelpers
  config.include OrganisationHelper
  config.include SearchHelper
  config.include VacanciesHelper
  config.include VacancyHelpers
  config.include JobseekerHelpers
  config.include ViewComponent::TestHelpers, type: :component
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_hosts "localhost", "127.0.0.1"
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
