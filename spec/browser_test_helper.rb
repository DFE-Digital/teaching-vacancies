require 'capybara/rspec'
require 'capybara/poltergeist'

# Setting js:errors to false because unrelated tests failed due to vanilla javascript code

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { phantomjs_options: ['--load-images=false'], js_errors: false })
end
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.before(:each, js: true, type: ->(v) { v != :smoke_test }) do
    page.driver.clear_memory_cache
  end
end
