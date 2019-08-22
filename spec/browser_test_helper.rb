require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--load-images=false'])
end
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.before(:each, js: true, :type => lambda {|v| v != :smoke_test}) do
    page.driver.clear_memory_cache
  end
end
