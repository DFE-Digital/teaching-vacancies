FactoryBot.define do
  factory :conversation do
    job_application

    archived { false }

    # A conversation can't be saved without a message, so give a created one a message
    # unless the test supplied its own. Built conversations have no messages.
    before(:create) do |conversation|
      conversation.messages << build(:publisher_message, conversation: conversation) if conversation.messages.empty?
    end
  end
end
