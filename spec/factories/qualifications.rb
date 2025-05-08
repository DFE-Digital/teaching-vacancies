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
    name { other? ? Faker::Educator.degree : "" }
    subject { undergraduate? || postgraduate? || other? ? Faker::Educator.subject : "" }
    year { finished_studying == false ? nil : factory_rand(1970..2020) }
    month { finished_studying == false ? nil : factory_rand(1..12) }

    job_application
  end
end
