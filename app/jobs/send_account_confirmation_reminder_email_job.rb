class SendAccountConfirmationReminderEmailJob < ApplicationJob
  queue_as :default

  def perform
    jobseekers.each(&:resend_confirmation_instructions)
  end

  def jobseekers
    Jobseeker.where(confirmation_sent_at: 5.days.ago.beginning_of_day..5.days.ago.end_of_day,
                    confirmed_at: nil)
  end
end
