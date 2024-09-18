class Jobseekers::RequestAccountTransferEmailForm < BaseForm
  attr_accessor :email

  validates :email, presence: true
  validates :email, email_address: true
  validate :validate_recent_code_request, if: -> { email.present? }

  def validate_recent_code_request
    jobseeker = Jobseeker.find_by(email: email)
    return if jobseeker.nil?

    return unless jobseeker.account_merge_confirmation_code_generated_at.present? && jobseeker.account_merge_confirmation_code_generated_at > 1.minute.ago

    errors.add(:email, :recent_code_request, message: I18n.t("jobseekers.request_account_transfer_emails.errors.recent_code_request"))
  end
end
