class Jobseekers::ReactivateAccount
  def self.reactivate(jobseeker)
    new(jobseeker).call
  end

  def initialize(jobseeker)
    @jobseeker = jobseeker
  end

  def call
    return unless @jobseeker.account_closed?

    mark_jobseeker_account_not_closed
    mark_subscriptions_active
  end

  private

  def mark_jobseeker_account_not_closed
    @jobseeker.update(account_closed_on: nil)
  end

  def mark_subscriptions_active
    Subscription
      .where(active: false, email: @jobseeker.email, unsubscribed_at: nil)
      .each { |s| s.update(active: true) }
  end
end
