FactoryBot.define do
  factory :publisher_preference do
    association :school_group
    association :publisher
    managed_organisations { "all" }
    managed_school_ids { [] }
  end
end
