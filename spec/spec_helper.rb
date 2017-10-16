require 'rake'
require 'elasticsearch/extensions/test/cluster/tasks'

RSpec.configure do |config|
  config.around :each, elasticsearch: true do |example|
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        model.__elasticsearch__.create_index!(force: true, index: model.index_name)
        model.__elasticsearch__.refresh_index! index: model.index_name
      end
    end

    example.run

    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        model.__elasticsearch__.delete_index!
      end
    end
  end

  # Don't start up any clusters on codeship - ES already running

  unless ENV['CI'] && ENV['CI_NAME'] == 'codeship'
    config.before :all do
      if test_cluster_offline?
        Elasticsearch::Model.client = Elasticsearch::Client.new(host: 'localhost:9250')
        Elasticsearch::Extensions::Test::Cluster.start(port: 9250, nodes: 1, timeout: 120)
      end
    end

    config.after :suite do
      if Elasticsearch::Extensions::Test::Cluster.running?(on: 9250)
        Elasticsearch::Extensions::Test::Cluster.stop(port: 9250)
      end
    end
  end

  def test_cluster_offline?
    !Elasticsearch::Extensions::Test::Cluster.running?(on: 9250)
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = nil
  config.order = :random
  Kernel.srand config.seed
end
