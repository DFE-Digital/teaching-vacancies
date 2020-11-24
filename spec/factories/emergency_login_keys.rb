FactoryBot.define do
  factory :emergency_login_key do
    not_valid_after { Date.current - 5.months }
    publisher
  end
end
