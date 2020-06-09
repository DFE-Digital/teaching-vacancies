FactoryBot.define do
  factory :emergency_login_key do
    not_valid_after { Time.zone.today - 5.months }
    user
  end
end
