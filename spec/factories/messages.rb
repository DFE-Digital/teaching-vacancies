FactoryBot.define do
  factory :publisher_message do
    sender { association(:publisher) }
    content { Faker::Lorem.paragraph }
    read { false }
    # Defined last so the message is complete when the conversation saves it alongside itself
    conversation { association(:conversation, publisher_messages: [instance]) }
  end

  factory :jobseeker_message do
    sender { association(:jobseeker) }
    content { Faker::Lorem.sentence }
    read { false }
    # Defined last so the message is complete when the conversation saves it alongside itself.
    # A jobseeker can only start a conversation once the application reaches interview
    conversation do
      association(:conversation,
                  job_application: association(:job_application, :status_interviewing),
                  publisher_messages: [],
                  jobseeker_messages: [instance])
    end
  end
end
