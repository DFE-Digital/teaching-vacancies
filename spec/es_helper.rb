require 'rake'
require 'elasticsearch/extensions/test/cluster/tasks'

RSpec.configure do |config|
  config.around :each, elasticsearch: true do |example|
    # Re-create the Elasticsearch index for vacancies (force: true removes any
    # data leftover from previous tests)
    Vacancy.__elasticsearch__.create_index!(force: true, index: Vacancy.index_name)

    example.run
  end

  # Don't start up any clusters on codeship - ES already running

  unless ENV['CI'] && ENV['CI_NAME'] == 'codeship'
    config.before :all, elasticsearch: true do
      if test_cluster_offline?
        Elasticsearch::Model.client = Elasticsearch::Client.new(host: 'localhost:9250')
        Elasticsearch::Extensions::Test::Cluster.start(port: 9250, nodes: 1, timeout: 120)
      end
    end

    config.after :suite do
      unless test_cluster_offline?
        Elasticsearch::Extensions::Test::Cluster.stop(port: 9250)
      end
    end
  end

  def test_cluster_offline?
    !Elasticsearch::Extensions::Test::Cluster.running?(on: 9250)
  end
end
