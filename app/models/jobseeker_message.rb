# frozen_string_literal: true

class JobseekerMessage < Message
  belongs_to :sender, class_name: "Jobseeker"

  validate :jobseeker_can_send_message

  private

  def jobseeker_can_send_message
    unless conversation.job_application.can_jobseeker_send_message?
      errors.add(:base, "Cannot send message for this job application status")
    end
  end
end
