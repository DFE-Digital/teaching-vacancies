# frozen_string_literal: true

class PublisherMessage < Message
  belongs_to :sender, class_name: "Publisher"

  validate :publisher_can_send_message, on: :create

  after_create :notify_jobseeker

  private

  def publisher_can_send_message
    unless conversation.job_application.can_publisher_send_message?
      errors.add(:base, "Cannot send message for this job application status")
    end
  end

  def notify_jobseeker
    Jobseekers::MessageReceivedNotifier.with(record: self).deliver
  end
end
