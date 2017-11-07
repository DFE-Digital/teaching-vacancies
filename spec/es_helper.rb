require 'rake'

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
end
