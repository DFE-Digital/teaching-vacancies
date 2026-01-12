class SendSubscriptionGovernanceEmailsJob < ApplicationJob
  queue_as :low

  def perform
    subscriptions_needing_governance_email.find_each do |subscription|
      send_appropriate_governance_email(subscription)
      subscription.update_column(:deletion_warning_email_sent_at, Time.current)
    end
  end

  private

  def subscriptions_needing_governance_email
    Subscription
      .where(updated_at: ...12.months.ago)
      .where(deletion_warning_email_sent_at: nil)
      .where(unsubscribed_at: nil)
  end

  def send_appropriate_governance_email(subscription)
    registered = Jobseeker.exists?(email: subscription.email.downcase)
    never_updated = subscription.created_at.to_i == subscription.updated_at.to_i

    mailer_method = if registered && never_updated
                      :governance_email_registered_never_updated
                    elsif registered && !never_updated
                      :governance_email_registered_was_updated
                    elsif !registered && never_updated
                      :governance_email_unregistered_never_updated
                    else # !registered && !never_updated
                      :governance_email_unregistered_was_updated
                    end

    Jobseekers::SubscriptionMailer.public_send(mailer_method, subscription).deliver_later
  end
end
