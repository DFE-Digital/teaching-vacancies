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
      .discarded.where(email: @jobseeker.email)
      .each { |s| s.undiscard }
  end
end
