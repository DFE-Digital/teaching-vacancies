class SendSubscriptionGovernanceEmailsJob < ApplicationJob
  queue_as :low

  def perform
    return if DisableEmailNotifications.enabled?

    subscriptions_needing_governance_email.find_each.with_index do |subscription, index|
      delay = index * GovukNotifyMailer::SIDEKIQ_WORKER_COUNT / GovukNotifyMailer::GOVUK_NOTIFY_SEND_LIMIT_PER_MINUTE

      mailer_method = appropriate_governance_email(subscription)
      Jobseekers::SubscriptionMailer.public_send(mailer_method, subscription).deliver_later(wait: delay.minutes)
      subscription.update_column(:deletion_warning_email_sent_at, Time.current)
    end
  end

  private

  def subscriptions_needing_governance_email
    Subscription
      .kept
      .where(updated_at: ...12.months.ago)
      .where(deletion_warning_email_sent_at: nil)
  end

  def appropriate_governance_email(subscription)
    registered = Jobseeker.exists?(email: subscription.email.downcase)
    never_updated = subscription.created_at.to_i == subscription.updated_at.to_i

    if registered && never_updated
      :governance_email_registered_never_updated
    elsif registered && !never_updated
      :governance_email_registered_was_updated
    elsif !registered && never_updated
      :governance_email_unregistered_never_updated
    else # !registered && !never_updated
      :governance_email_unregistered_was_updated
    end
  end
end
