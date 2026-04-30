FactoryBot.define do
  factory :vacancy_template do
    name { Faker::Book.title }
    job_roles { %w[teacher] }
    phases { %w[primary] }
    key_stages { %w[ks1] }
    contract_type { :fixed_term }
    fixed_term_contract_duration { "6 months" }
    is_parental_leave_cover { true }
    is_job_share { false }
    working_patterns { %w[full_time] }
    salary { factory_rand(20_000..100_000) }
    ect_status { :ect_suitable }
    school_offer { Faker::Lorem.sentence(word_count: factory_rand(10..20)) }
    flexi_working_details_provided { false }
    skills_and_experience { Faker::Lorem.sentence(word_count: factory_rand(10..30)) }
    further_details_provided { false }
    benefits { false }
    school_visits { false }
    visa_sponsorship_available { false }
    enable_job_applications { true }
    anonymise_applications { false }

    trait :secondary do
      phases { %w[secondary] }
    end

    trait :it_support do
      job_roles { %w[it_support] }
    end

    trait :website do
      enable_job_applications { false }
      receive_applications { :website }
    end
  end
end
