FactoryBot.define do
  factory :job_reference do
    complete { false }

    trait :reference_given do
      complete { true }
      can_give_reference { true }
      name { "name" }
      job_title { "job_title" }
      phone_number { "01234 5654345" }
      email { Faker::Internet.email(domain: "contoso.com") }
      organisation { "my school" }

      how_do_you_know_the_candidate { Faker::Lorem.paragraph }
      reason_for_leaving { "no reason" }
      would_reemploy_current_reason { "wonderful" }
      would_reemploy_any_reason { "fantastic" }

      currently_employed { false }
      would_reemploy_current { true }
      would_reemploy_any { true }
      employment_start_date { Faker::Date.between(from: Date.new(2012, 1, 1), to: Date.new(2017, 1, 1)) }
      employment_end_date { Faker::Date.between(from: Date.new(2017, 1, 1), to: Date.new(2022, 1, 1)) }

      under_investigation { false }
      warnings { false }
      allegations { false }
      not_fit_to_practice { false }
      able_to_undertake_role { true }
      under_investigation_details { Faker::Lorem.sentence }
      warning_details { Faker::Lorem.sentence }
      unable_to_undertake_reason { Faker::Lorem.sentence }

      punctuality { "outstanding" }
      working_relationships { "outstanding" }
      customer_care { "outstanding" }
      adapt_to_change { "outstanding" }
      deal_with_conflict { "outstanding" }
      prioritise_workload { "outstanding" }

      team_working { "good" }
      communication { "outstanding" }
      problem_solving { "outstanding" }
      general_attitude { "outstanding" }
      technical_competence { "poor" }
      leadership { "outstanding" }
    end

    trait :with_issues do
      complete { true }
      under_investigation { true }
      warnings { true }
      able_to_undertake_role { false }

      under_investigation_details { Faker::Lorem.paragraph }
      warning_details { Faker::Lorem.paragraph }
      unable_to_undertake_reason { Faker::Lorem.paragraph }
    end

    trait :reference_declined do
      complete { true }
      can_give_reference { false }
    end
  end

  factory :reference_request do
    token { SecureRandom.uuid }
    status { :requested }
    email { Faker::Internet.email(domain: "contoso.com") }
  end
end
