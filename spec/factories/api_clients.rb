FactoryBot.define do
  factory :api_client do
    name { "Big MAT ATS" }
    api_key { SecureRandom.hex(20) }
    last_rotated_at { "2024-11-06 14:31:03" }
  end
end
