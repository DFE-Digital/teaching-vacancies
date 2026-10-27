FactoryBot.define do
  factory :conversation do
    job_application

    archived { false }
    # A conversation can't be saved without a message
    publisher_messages { [association(:publisher_message, conversation: instance, strategy: :build)] }
  end
end
