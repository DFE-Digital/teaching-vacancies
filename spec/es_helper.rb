require 'rake'

RSpec.configure do |config|
  config.around :each, elasticsearch: true do |example|
    # Re-create the Elasticsearch index for vacancies (force: true removes any
    # data leftover from previous tests)
    Vacancy.__elasticsearch__.create_index!(force: true, index: Vacancy.index_name)

    example.run
  end
end
