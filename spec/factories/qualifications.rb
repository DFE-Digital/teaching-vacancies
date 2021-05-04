FactoryBot.define do
  factory :qualification do
    after(:create) do |qualification, evaluator|
      next unless qualification.secondary?

      create_list(:qualification_result, evaluator.results_count, qualification: qualification)
    end

    transient do
      # Number of results to add _if_ a secondary qualification is created
      results_count { 5 }
    end

    category { Qualification.categories.keys.sample.to_s }
    finished_studying { undergraduate? || postgraduate? ? Faker::Boolean.boolean : nil }
    finished_studying_details { finished_studying.nil? || finished_studying? ? "" : "Stopped due to illness" }
    grade { finished_studying.nil? || finished_studying? ? %w[A B C D E F].sample : "" }
    institution { undergraduate? || postgraduate? || other? ? Faker::Educator.university : Faker::Educator.secondary_school }
    name { other_secondary? || other? ? Faker::Educator.degree : "" }
    subject { Faker::Educator.subject }
    year { finished_studying.nil? || finished_studying? ? rand(1970..2020) : nil }

    job_application
  end
end
