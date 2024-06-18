FactoryBot.define do
  factory :qualification do
    after(:create) do |qualification, evaluator|
      next unless qualification.secondary?

      create_list(:qualification_result, evaluator.results_count, qualification: qualification)
      qualification.reload
    end

    transient do
      # Number of results to add _if_ a secondary qualification is created
      results_count { 5 }
    end

    category { factory_sample(Qualification.categories.keys) }
    finished_studying { undergraduate? || postgraduate? || other? ? Faker::Boolean.boolean : nil }
    finished_studying_details { finished_studying == false ? "Stopped due to illness" : "" }
    grade do
      if finished_studying?
        undergraduate? || postgraduate? ? factory_sample(["2.1", "2.2", "Honours"]) : factory_sample(%w[Pass Merit Distinction])
      else
        ""
      end
    end
    institution { secondary? ? Faker::Educator.secondary_school : Faker::Educator.university }
    name { other_secondary? || other? ? Faker::Educator.degree : "" }
    subject { undergraduate? || postgraduate? || other? ? Faker::Educator.subject : "" }
    year { finished_studying == false ? nil : factory_rand(1970..2020) }

    association :job_application
  end

  trait :category_undergraduate do
    results_count { 1 }
    category { 4 }
    year { 2016 }
    subject { "BA English Literature " }
    grade { "2.1" }
  end

  trait :category_other do
    results_count { 1 }
    category { 6 }
    year { 2019 }
    subject { "PGCE English with QTS " }
  end

  trait :category_a_level do
    category { 2 }
    year { 2012 }

    qualification_results do
      [
        association(:qualification_result, :category_alevel_sample1),
        association(:qualification_result, :category_alevel_sample2),
        association(:qualification_result, :category_alevel_sample3),
      ]
    end
  end

  trait :category_gcse do
    category { 0 }
    year { 2010 }

    qualification_results do
      [
        association(:qualification_result, :category_gcse_sample1),
        association(:qualification_result, :category_gcse_sample2),
        association(:qualification_result, :category_gcse_sample3),
        association(:qualification_result, :category_gcse_sample4),
        association(:qualification_result, :category_gcse_sample5),
        association(:qualification_result, :category_gcse_sample6),
        association(:qualification_result, :category_gcse_sample7),
      ]
    end
  end
end
