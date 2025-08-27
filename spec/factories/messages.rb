FactoryBot.define do
  factory :publisher_message do
    conversation
    sender { association(:publisher) }
    content { "This is a test message content." }

    trait :with_rich_content do
      content { "<p>This message contains <strong>rich text</strong> formatting.</p>" }
    end
  end

  factory :jobseeker_message do
    conversation
    sender { association(:jobseeker) }
    content { "This is a test message content." }

    trait :with_rich_content do
      content { "<p>This message contains <strong>rich text</strong> formatting.</p>" }
    end
  end
end
