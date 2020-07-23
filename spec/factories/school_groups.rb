FactoryBot.define do
  factory :school_group do
    uid { Faker::Number.number(digits: 5).to_s }
    gias_data { {
      "Group UID": uid,
      "Group Name": 'Trust name',
      "Group Type": 'Trust type'
    } }
  end
end
