class SendPeakTimesEmailReminderJob < ApplicationJob
  queue_as :default

  def perform
    Jobseeker.email_opt_in.select(:id).find_each do |jobseeker|
      Jobseekers::PeakTimesMailer.reminder(jobseeker.id).deliver_later
    end
  end
end
