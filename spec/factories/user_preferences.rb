FactoryBot.define do
  factory :user_preference do
    association :school_group
    association :user
    managed_organisations { "all" }
    managed_school_ids { [] }
  end
end
