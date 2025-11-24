class DestroyInactiveAccountsJob < ApplicationJob
  queue_as :default

  def perform
    return if DisableExpensiveJobs.enabled?

    Jobseeker.where(last_sign_in_at: ..6.years.ago).each do |jobseeker|
      Subscription.where(email: jobseeker.email).destroy_all
      Feedback.where(email: jobseeker.email).destroy_all
      Feedback.where(jobseeker:).destroy_all
      jobseeker.destroy!
    end
  end
end
