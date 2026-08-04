class SendInactiveAccountEmailJob < ApplicationJob
  queue_as :default

  def perform
    return if DisableEmailNotifications.enabled?

    Jobseeker.send_inactive_warning_message.each do |jobseeker|
      Jobseekers::AccountMailer.inactive_account(jobseeker).deliver_later
    end
  end
end
