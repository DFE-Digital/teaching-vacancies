# frozen_string_literal: true

class PublisherMessage < Message
  belongs_to :sender, class_name: "Publisher"

  validate :publisher_can_send_message

  private

  def publisher_can_send_message
    unless conversation.job_application.can_publisher_send_message?
      errors.add(:base, "Cannot send message for this job application status")
    end
  end
end
