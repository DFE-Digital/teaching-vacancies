FactoryBot.define do
  factory :publisher_message do
    conversation
    sender { association(:publisher) }
    content { Faker::Lorem.paragraph }
    read { false }
  end

  factory :jobseeker_message do
    conversation
    sender { association(:jobseeker) }
    content { Faker::Lorem.sentence }
    read { false }
  end
end
