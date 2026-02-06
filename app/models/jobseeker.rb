class Jobseeker < ApplicationRecord
  has_encrypted :last_sign_in_ip, :current_sign_in_ip

  devise(*%I[
    timeoutable
    trackable
  ])

  has_many :feedbacks, dependent: :destroy, inverse_of: :jobseeker
  has_many :job_applications, dependent: :destroy
  has_many :native_job_applications
  has_many :uploaded_job_applications
  has_many :saved_jobs, dependent: :destroy
  has_many :emergency_login_keys, as: :owner
  has_many :jobseeker_messages, foreign_key: :sender_id, dependent: :destroy
  has_one :jobseeker_profile, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"

  scope :active, -> { where(account_closed_on: nil) }
  scope :email_opt_in, -> { active.where(email_opt_out: false) }

  scope :very_inactive_will_be_deleted, -> { where(last_sign_in_at: ..6.years.ago) }
  scope :send_inactive_warning_message, -> { where("DATE(last_sign_in_at) = ?", (6.years.ago + 2.weeks).to_date) }

  validates :email, presence: true, uniqueness: true
  validates :email, email_address: true, if: -> { email_changed? } # Allows data created prior to validation to still be valid
  validates :govuk_one_login_id, uniqueness: true, allow_nil: true

  validates :email_opt_out_reason, presence: true, if: -> { email_opt_out }

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

  def has_submitted_native_job_application?
    native_job_applications.not_draft.any?
  end

  def generate_merge_verification_code
    self.account_merge_confirmation_code = SecureRandom.alphanumeric(6)
    self.account_merge_confirmation_code_generated_at = Time.current
    save!
  end

  def papertrail_display_name
    jobseeker_profile&.full_name || "Jobseeker"
  end
  #
  # GovUK OneLogin methods
  #
  # Specific methods to deal with GovUK OneLogin integration.
  #
  class << self
    # Creates a new Jobseeker from the GovUK OneLogin id and email address.
    def create_from_govuk_one_login(id:, email:)
      return unless email.present? && id.present?

      create!(email: email.downcase, govuk_one_login_id: id)
    end

    # Either find the Jobseeker by their GovUK OneLogin id or uses the OneLogin email address to find:
    # - Jobseekers created before introducing OneLogin and still non-linked with a OneLogin account.
    # - Jobseekers that deleted their GovUK OneLogin account, created a new one with the same email but different id.
    def find_from_govuk_one_login(id:, email:)
      find_by(govuk_one_login_id: id) || find_by(email: email)
    end
  end

  # Unlinks the Jobseeker from GovUK OneLogin by removing the OneLogin id.
  #
  # This method is not currently called anywhere in the codebase, but is made available for developers to use in the
  # console to resolve support requests.
  #
  def unlink_from_govuk_one_login!
    update!(govuk_one_login_id: nil) if govuk_one_login_id.present?
  end

  # Updates the Jobseeker's email address with the one provided by GovUK OneLogin.
  def update_email_from_govuk_one_login!(new_email)
    return false if new_email.blank? || new_email == email

    # Find any Jobseeker with the new email address that was created before OneLogin was introduced.
    if (legacy_user = self.class.find_by(email: new_email, govuk_one_login_id: nil))
      return false if saved_data_preventing_transfer? # Do not update email or transfer account if the current user has any saved data.

      Jobseekers::AccountTransfer.new(self, legacy_user.email).call
    end
    update!(email: new_email)
  end
  #
  # End of GovUK OneLogin methods
  #

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

  def saved_data_preventing_transfer?
    job_applications.any? || jobseeker_profile&.qualifications&.any? || jobseeker_profile&.employments&.any?
  end
end
