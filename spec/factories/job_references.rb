FactoryBot.define do
  factory :job_reference do
    complete { true }
    token { SecureRandom.uuid }
    name { "name" }
    job_title { "job_title" }
    phone_number { "01234 5654345" }
    email { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
    organisation { "my school" }

    how_do_you_know_the_candidate { "well" }
    reason_for_leaving { "no reason" }
    would_reemploy_current_reason { "wonderful" }
    would_reemploy_any_reason { "fantastic" }

    currently_employed { true }
    would_reemploy_current { true }
    would_reemploy_any { true }
  end
end
