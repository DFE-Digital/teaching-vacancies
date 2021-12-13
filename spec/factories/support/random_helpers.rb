module RandomHelpers
  def factory_rand(range)
    if Rails.env.test?
      range.min
    else
      rand(range)
    end
  end

  def factory_sample(things, num = 1)
    if Rails.env.test?
      num == 1 ? things.first : things.take(num)
    else
      num == 1 ? things.sample : things.sample(num)
    end
  end

  def factory_rand_sample(things, range)
    factory_sample(things, factory_rand(range))
  end
end

FactoryBot::SyntaxRunner.include(RandomHelpers)
