class DestroyInactiveAccountsJob < ApplicationJob
  queue_as :default

  def perform_now
    return if DisableExpensiveJobs.enabled?

    Jobseeker.where("DATE(last_sign_in_at) = ?", (5.years.ago - 2.weeks).to_date).each do |jobseeker|
      Subscription.where(email: jobseeker.email).destroy_all
      Feedback.where(email: jobseeker.email).destroy_all
      Feedback.where(jobseeker:).destroy_all
      jobseeker.destroy
    end
  end
end
