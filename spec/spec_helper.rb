require 'webmock/rspec'
require 'rack_session_access/capybara'

RSpec.configure do |config|
  allowed_http_requests = [
    'localhost',
    '127.0.0.1', # Required for Capybara sessions
    'es', # Required for CI. Defined in ./buildspec.yml
    'pg', # Required for CI. Defined in ./buildspec.yml
  ]
  WebMock.disable_net_connect!(allow: allowed_http_requests)

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.filter_run_excluding algolia: true
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = nil
  config.order = :random
  Kernel.srand config.seed

  config.before(:each) do
    ENV.delete('OVERRIDE_SCHOOL_URN')
  end
end
