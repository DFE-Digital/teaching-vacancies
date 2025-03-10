class Jobseeker < ApplicationRecord
  has_encrypted :last_sign_in_ip, :current_sign_in_ip

  devise(*%I[
    timeoutable
    trackable
  ])

  has_many :feedbacks, dependent: :destroy, inverse_of: :jobseeker
  has_many :job_applications, dependent: :destroy
  has_many :saved_jobs, dependent: :destroy
  has_many :emergency_login_keys, as: :owner
  has_one :jobseeker_profile

  validates :email, presence: true, uniqueness: true
  validates :email, email_address: true, if: -> { email_changed? } # Allows data created prior to validation to still be valid
  validates :govuk_one_login_id, uniqueness: true, allow_nil: true

  validates :email_opt_out_reason, presence: true, if: -> { email_opt_out  }
  validates :email_opt_out_comment, presence: true, if: -> { email_opt_out && email_opt_out_reason&.to_sym == :other_reason }

  enum :email_opt_out_reason, {
    too_many_emails: 0,
    not_getting_any_value: 1,
    not_looking_for_job: 2,
    other_reason: 3,
  }

  after_update :update_subscription_emails
  after_update :create_email_opt_out_feedback, if: -> { saved_change_to_attribute?(:email_opt_out) && email_opt_out? }

  def update_subscription_emails
    return unless saved_change_to_attribute?(:email)

    Subscription.where(email: email_previously_was).update(email: email)
  end

  def account_closed?
    !!account_closed_on
  end

  def generate_merge_verification_code
    self.account_merge_confirmation_code = SecureRandom.alphanumeric(6)
    self.account_merge_confirmation_code_generated_at = Time.current
    save!
  end

  def update_email_from_govuk_one_login!(new_email)
    return false if new_email.blank? || new_email == email

    # Find any Jobseeker with the new email address that was created before OneLogin was introduced.
    if (legacy_user = self.class.find_by(email: new_email, govuk_one_login_id: nil))
      return false if saved_data?

      Jobseekers::AccountTransfer.new(self, legacy_user.email).call
    end
    update!(email: new_email)
  end

  # Criteria used for determining if a Jobseeker has enough saved data to be considered for automatic account transfer.
  def saved_data?
    job_applications.any? || jobseeker_profile&.qualifications&.any? || jobseeker_profile&.employments&.any?
  end

  def self.create_from_govuk_one_login(id:, email:)
    return unless email.present? && id.present?

    create!(email: email.downcase, govuk_one_login_id: id)
  end

  # Either find the Jobseeker by their GovUK OneLogin id or uses the OneLogin email address to find possible Jobseekers
  # created before introducingq OneLogin and still non-linked with a OneLogin account.
  def self.find_from_govuk_one_login(id:, email:)
    find_by(govuk_one_login_id: id) || find_by(email: email)
  end

  OPT_OUT_TO_UNSUBSCRIBE_REASON = {
    too_many_emails: :not_relevant,
    not_getting_any_value: :circumstances_change,
    not_looking_for_job: :job_found,
    other_reason: :other_reason,
  }.freeze

  private

  def create_email_opt_out_feedback
    feedbacks.create(
      feedback_type: :email_preferences,
      unsubscribe_reason: OPT_OUT_TO_UNSUBSCRIBE_REASON.fetch(email_opt_out_reason.to_sym),
      job_found_unsubscribe_reason_comment: email_opt_out_comment,
    )
  end
end
