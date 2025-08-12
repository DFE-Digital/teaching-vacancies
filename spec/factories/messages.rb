FactoryBot.define do
  factory :message do
    conversation
    sender { association(:publisher) }
    content { "This is a test message content." }

    trait :from_publisher do
      sender { association(:publisher) }
    end

    trait :from_jobseeker do
      sender { association(:jobseeker) }
    end

    trait :with_rich_content do
      content { "<p>This message contains <strong>rich text</strong> formatting.</p>" }
    end
  end
end