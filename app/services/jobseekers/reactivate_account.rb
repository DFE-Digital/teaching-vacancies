class Jobseekers::ReactivateAccount
  attr_reader :jobseeker

  def initialize(jobseeker)
    @jobseeker = jobseeker
  end

  def call
    mark_jobseeker_account_not_closed
    mark_subscriptions_active
  end

  private

  def mark_jobseeker_account_not_closed
    jobseeker.update(closed_account: false)
  end

  def mark_subscriptions_active
    Subscription.where(active: false, email: jobseeker.email, unsubscribed_at: nil)
                .each { |subscription| subscription.update(active: true) }
  end
end
