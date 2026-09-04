class DestroyInactiveAccountsJob < ApplicationJob
  queue_as :default

  def perform
    # simplecov:disable
    return if DisableExpensiveJobs.enabled?

    # simplecov:enable

    Jobseeker.very_inactive_will_be_deleted.each do |jobseeker|
      Subscription.where(email: jobseeker.email).destroy_all
      Feedback.where(email: jobseeker.email).destroy_all
      Feedback.where(jobseeker:).destroy_all
      jobseeker.destroy!
    end
  end
end
