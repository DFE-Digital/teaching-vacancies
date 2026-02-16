# frozen_string_literal: true

class JobseekerMessage < Message
  belongs_to :sender, class_name: "Jobseeker"

  validate :jobseeker_can_send_message, on: :create

  after_create :notify_publisher
  after_save :update_conversation_unread_status

  private

  def jobseeker_can_send_message
    unless conversation.job_application.can_jobseeker_send_message?
      errors.add(:base, "Cannot send message for this job application status")
    end
  end

  def notify_publisher
    Publishers::MessageReceivedNotifier.with(record: self).deliver
  end

  def update_conversation_unread_status
    conversation.with_lock do
      unread = conversation.jobseeker_messages.exists?(read: false)
      if conversation.has_unread_jobseeker_messages != unread
        conversation.update!(has_unread_jobseeker_messages: unread)
      end
    end
  end
end
