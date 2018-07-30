RSpec.configure do |config|
  DatabaseCleaner.allow_remote_database_url = true

  config.use_transactional_fixtures = false
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = if Capybara.current_driver == :rack_test
                                 :transaction
                               else
                                 :truncation
                               end
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
