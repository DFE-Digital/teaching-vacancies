class SendJobApplicationDataExpiryNotificationJob < ApplicationJob
  queue_as :default

  def perform_now
    # return if DisableExpensiveJobs.enabled?

    Vacancy.includes(organisations: :publishers).where("DATE(expires_at) = ?", 351.days.ago.to_date).each do |vacancy|
      vacancy.organisation.publishers.each do |publisher|
        Publishers::JobApplicationDataExpiryNotification.with(vacancy: vacancy, publisher: publisher).deliver(publisher) if publisher.email == "mili.malde@digital.education.gov.uk"
      end
    end
  end
end
