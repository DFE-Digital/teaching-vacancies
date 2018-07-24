require 'capybara/rspec'
require 'capybara/poltergeist'

if ENV['TEST_BROWSER'] == 'browserstack'
  require 'yaml'
  require 'browserstack/local'

  WebMock.disable_net_connect!(allow_localhost: true, allow: /browserstack/)

  # monkey patch to avoid reset sessions
  class Capybara::Selenium::Driver < Capybara::Driver::Base
    def reset!
      if @browser
        @browser.navigate.to('about:blank')
      end
    end
  end

  CONFIG = YAML.load(File.read(File.join(File.dirname(__FILE__), '../config/browserstack.yml')))
  CONFIG['user'] = ENV['BROWSERSTACK_USERNAME']
  CONFIG['key'] = ENV['BROWSERSTACK_ACCESS_KEY']

  Capybara.register_driver :browserstack do |app|
    caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][0])
    caps["browserstack.local"] = true

    @browserstack_local = BrowserStack::Local.new
    @browserstack_local.start({"key" => "#{CONFIG['key']}", "forcelocal" => true})

    Capybara::Selenium::Driver.new(app,
      browser: :remote,
      url: "http://#{CONFIG['user']}:#{CONFIG['key']}@hub-cloud.browserstack.com/wd/hub",
      desired_capabilities: caps
    )
  end

  Capybara.default_driver = :browserstack
  Capybara.javascript_driver = :browserstack
  Capybara.current_driver = :browserstack
  Capybara.run_server = true

  at_exit do
    @browserstack_local.stop unless @browserstack_local.nil?
  end

  puts "Running specs with BrowserStack"

else

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--load-images=false'])
  end
  Capybara.javascript_driver = :poltergeist

end