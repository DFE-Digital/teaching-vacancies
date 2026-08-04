class SendMessagesReceivedYesterdayJob < ApplicationJob
  queue_as :low

  def perform
    publishers_with_messages_received_yesterday.each do |publisher|
      next unless publisher.email?

      message_count = count_messages_for_publisher(publisher)
      Publishers::MessageNotificationMailer.messages_received(publisher: publisher, message_count: message_count).deliver
    end
  end

  private

  def publishers_with_messages_received_yesterday
    Publisher.distinct
             .joins(organisations: { vacancies: { job_applications: { conversations: :messages } } })
             .where(messages: { type: "JobseekerMessage", read: false })
             .where(messages: { created_at: Date.yesterday.all_day })
  end

  def count_messages_for_publisher(publisher)
    JobseekerMessage
      .joins(conversation: { job_application: { vacancy: { organisations: :publishers } } })
      .where(messages: { created_at: Date.yesterday.all_day })
      .where(messages: { read: false })
      .where(publishers: { id: publisher.id })
      .count
  end
end
