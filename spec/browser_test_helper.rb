require 'capybara/rspec'
require 'capybara/poltergeist'

if ENV['TEST_BROWSER'] == 'browserstack'
  require 'yaml'
  require 'browserstack/local'

  # monkey patch to avoid reset sessions
  class Capybara::Selenium::Driver < Capybara::Driver::Base
    def reset!
      @browser&.navigate&.to('about:blank')
    end
  end

  CONFIG ||= YAML.safe_load(File.read(File.join(File.dirname(__FILE__), '../config/browserstack.yml')))
  TASK_ID = ENV['TASK_ID'] ||= '0'

  Capybara.register_driver :browserstack do |app|
    caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID.to_i])
    caps['browserstack.local'] = true

    @browserstack_local = BrowserStack::Local.new
    @browserstack_local.start('key' => (ENV['BROWSERSTACK_ACCESS_KEY']).to_s, 'forcelocal' => true)

    url = "http://#{ENV['BROWSERSTACK_USERNAME']}:#{ENV['BROWSERSTACK_ACCESS_KEY']}@hub-cloud.browserstack.com/wd/hub"
    Capybara::Selenium::Driver.new(app,
                                   browser: :remote,
                                   url: url,
                                   desired_capabilities: caps)
  end

  Capybara.default_driver = :browserstack
  Capybara.javascript_driver = :browserstack
  Capybara.current_driver = :browserstack
  Capybara.run_server = true
  Capybara.ignore_hidden_elements = false

  at_exit do
    @browserstack_local&.stop
  end

  puts "Running specs with BrowserStack using #{CONFIG['browser_caps'][TASK_ID.to_i]['browser']}"

else

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--load-images=false'])
  end
  Capybara.javascript_driver = :poltergeist
end
