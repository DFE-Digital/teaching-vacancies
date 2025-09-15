class SendMessagesReceivedYesterdayJob < ApplicationJob
  queue_as :low

  def perform
    publishers_with_messages_received_yesterday.each do |publisher|
      next unless publisher.email?

      message_count = count_messages_for_publisher(publisher)
      Publishers::MessageNotificationMailer.messages_received(publisher: publisher, message_count: message_count).deliver
      Rails.logger.info("Sidekiq: Sending messages received yesterday for publisher id: #{publisher.id}, count: #{message_count}")
    end
  end

  private

  def publishers_with_messages_received_yesterday
    Publisher.distinct
             .joins(organisations: { vacancies: { job_applications: { conversations: :messages } } })
             .where(messages: { type: "JobseekerMessage", read: false })
             .where("DATE(messages.created_at) = ?", Date.yesterday)
  end

  def count_messages_for_publisher(publisher)
    JobseekerMessage
      .joins(conversation: { job_application: { vacancy: { organisations: :publishers } } })
      .where("DATE(messages.created_at) = ?", Date.yesterday)
      .where(messages: { read: false })
      .where(publishers: { id: publisher.id })
      .count
  end
end
