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

  validates :email, presence: true, email_address: true
  validates :govuk_one_login_id, uniqueness: true, allow_nil: true

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

  def self.find_or_create_from_govuk_one_login(email:, govuk_one_login_id:)
    return unless email.present? && govuk_one_login_id.present?

    if (user = find_by("LOWER(email) = ?", email.downcase))
      user.update(govuk_one_login_id: govuk_one_login_id) if user.govuk_one_login_id != govuk_one_login_id
      user
    else
      # OneLogin users won't need/use this password. But is required by validations for in-house Devise users.
      # Eventually when all the users become OneLogin users, we should be able to remove the password requirement.
      random_password = Devise.friendly_token
      create!(email: email.downcase,
              govuk_one_login_id: govuk_one_login_id,
              password: random_password,
              confirmed_at: Time.zone.now)
    end
  end

  def generate_merge_verification_code
    self.account_merge_confirmation_code = SecureRandom.alphanumeric(6)
    self.account_merge_confirmation_code_generated_at = Time.current
    save!
  end
end
