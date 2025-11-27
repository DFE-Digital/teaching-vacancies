class SendInactiveAccountEmailJob < ApplicationJob
  queue_as :default

  def perform
    return if DisableEmailNotifications.enabled?

    Jobseeker.where("DATE(last_sign_in_at) = ?", 5.years.ago.to_date).each do |jobseeker|
      Jobseekers::AccountMailer.inactive_account(jobseeker).deliver_later
    end
  end
end
