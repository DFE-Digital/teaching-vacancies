class SendPeakTimesEmailReminderJob < SidekiqJob
  queue_as :default

  def perform
    Jobseeker.email_opt_in.select(:id).find_each.with_index do |jobseeker, index|
      delay = index * GovukNotifyMailer::SIDEKIQ_WORKER_COUNT / GovukNotifyMailer::GOVUK_NOTIFY_SEND_LIMIT_PER_MINUTE
      Jobseekers::PeakTimesMailer.reminder(jobseeker.id).deliver_later(wait: delay.minutes)
    end
  end
end
