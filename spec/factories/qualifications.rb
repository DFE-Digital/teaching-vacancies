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

    category { Qualification.categories.keys.sample }
    finished_studying { undergraduate? || postgraduate? ? Faker::Boolean.boolean : nil }
    finished_studying_details { finished_studying == false ? "Stopped due to illness" : "" }
    grade { !finished_studying? ? "" : ["2.1", "Flying Colours", "Honours"].sample }
    institution { secondary? ? Faker::Educator.secondary_school : Faker::Educator.university }
    name { other_secondary? || other? ? Faker::Educator.degree : "" }
    subject { undergraduate? || postgraduate? ? Faker::Educator.subject : "" }
    year { finished_studying == false ? nil : rand(1970..2020) }

    job_application
  end
end
