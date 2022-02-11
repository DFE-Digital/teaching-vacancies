class Jobseeker < ApplicationRecord
  lockbox_encrypts :last_sign_in_ip, :current_sign_in_ip

  devise(*%I[
    confirmable
    database_authenticatable
    lockable
    recoverable
    registerable
    timeoutable
    trackable
    validatable
  ])

  has_many :feedbacks
  has_many :job_applications, dependent: :destroy
  has_many :saved_jobs, dependent: :destroy

  after_update :update_subscription_emails

  def update_subscription_emails
    return unless saved_change_to_attribute?(:email)

    Subscription.where(email: email_previously_was).update(email: email)
  end

  def account_closed?
    !!account_closed_on
  end
end
