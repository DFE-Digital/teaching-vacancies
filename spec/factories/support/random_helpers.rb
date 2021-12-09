module RandomHelpers
  module Definitions
    def deterministic_sequence(*args, &block)
      return sequence(*args, &block) unless Rails.env.test?

      sequence(*args) do |n|
        # prev_random = Faker::Config.random
        # Faker::Config.random = Random.new(n)
        block.yield n
        # Faker::Config.random = prev_random
      end
    end
  end

  module Syntax
    def factory_rand(range)
      if Rails.env.test?
        range.min
      else
        rand(range)
      end
    end

    def factory_sample(things, num = 1)
      if Rails.env.test?
        num == 1 ? things.first : things[0...num]
      else
        things.sample(num)
      end
    end

    def factory_rand_sample(things, range)
      factory_sample(things, factory_rand(range))
    end
  end
end

FactoryBot::DefinitionProxy.include(RandomHelpers::Definitions)
FactoryBot::SyntaxRunner.include(RandomHelpers::Syntax)

if Rails.env.test?
  Faker::Config.random = Random.new(123)

  RSpec.configure do |config|
    config.after do
      FactoryBot.rewind_sequences
    end
  end
end
