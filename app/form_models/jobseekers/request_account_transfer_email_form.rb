class Jobseekers::RequestAccountTransferEmailForm < BaseForm
  attr_accessor :email, :email_resent, :current_jobseeker_email

  validates :email, presence: true
  validates :email, email_address: true
  validate :validate_recent_code_request, if: -> { email.present? }
  validate :validate_account_to_transfer_is_not_the_currently_logged_in_user, if: -> { email.present? }

  def validate_recent_code_request
    jobseeker = Jobseeker.find_by(email: email.downcase)
    return if jobseeker.nil?

    return unless jobseeker.account_merge_confirmation_code_generated_at.present? && jobseeker.account_merge_confirmation_code_generated_at > 1.minute.ago

    errors.add(:email, :recent_code_request, message: I18n.t("jobseekers.request_account_transfer_emails.errors.recent_code_request"))
  end

  def validate_account_to_transfer_is_not_the_currently_logged_in_user
    return unless email.downcase == current_jobseeker_email.downcase

    errors.add(:email, :cannot_transfer_to_same_account, message: I18n.t("jobseekers.request_account_transfer_emails.errors.cannot_transfer_logged_in_account"))
  end
end
