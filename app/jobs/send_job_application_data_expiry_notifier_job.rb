class SendJobApplicationDataExpiryNotifierJob < ApplicationJob
  queue_as :default

  def perform_now
    return if DisableExpensiveJobs.enabled?

    Vacancy.includes(organisations: :publishers).where("DATE(expires_at) = ?", 351.days.ago.to_date).each do |vacancy|
      next unless vacancy.job_applications.any?

      vacancy.organisation.publishers.each do |publisher|
        Publishers::JobApplicationDataExpiryNotifier.with(vacancy: vacancy, publisher: publisher).deliver(publisher)
      end
    end
  end
end
