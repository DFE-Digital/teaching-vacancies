class Jobseeker < ApplicationRecord
  has_encrypted :last_sign_in_ip, :current_sign_in_ip

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

  has_many :feedbacks, dependent: :destroy, inverse_of: :jobseeker
  has_many :job_applications, dependent: :destroy
  has_many :saved_jobs, dependent: :destroy
  has_one :jobseeker_profile

  validates :email, presence: true
  validates :email, email_address: true, if: -> { email_changed? } # Allows data created prior to validation to still be valid

  after_update :update_subscription_emails

  def update_subscription_emails
    return unless saved_change_to_attribute?(:email)

    Subscription.where(email: email_previously_was).update(email: email)
  end

  def account_closed?
    !!account_closed_on
  end

  def needs_email_confirmation?
    !confirmed? || unconfirmed_email.present?
  end

  def generate_merge_verification_code
    self.account_merge_confirmation_code = SecureRandom.alphanumeric(6)
    self.account_merge_confirmation_code_generated_at = Time.current
    save!
  end
end
