require 'spec_helper'
require 'es_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'factory_bot_rails'
require 'database_cleaner_helper'
require 'browser_test_helper'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

user_agents ||= YAML.load_file(Browser.root.join('test/ua.yml')).freeze
USER_AGENTS = user_agents

# This keeps the startup message from appearing in the stdout of the test run.
Capybara.server = :puma, { Silent: true, Threads: '0:1' }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods

  config.before do
    stub_const("#{SalaryValidator}::MIN_SALARY_ALLOWED", '1')
  end

  config.before(:each, :sitemap) do
    default_url_options[:host] = DOMAIN.to_s
  end

  config.include ActionView::Helpers::NumberHelper
  config.include ApplicationHelpers
  config.include DateHelper
  config.include VacancyHelpers
  config.include AuthHelpers
  config.include CapybaraHelper, type: :feature
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

require 'sidekiq/testing'
Sidekiq::Testing.fake!
