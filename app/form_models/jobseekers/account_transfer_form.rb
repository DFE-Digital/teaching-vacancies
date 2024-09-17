class Jobseekers::AccountTransferForm < BaseForm
  attr_accessor :email, :account_merge_confirmation_code
  validates :email, presence: true
  validates :email, email_address: true
  validates :account_merge_confirmation_code, presence: true
  validate :validate_jobseeker_email_and_code_match

  private

  def validate_jobseeker_email_and_code_match
    jobseeker = Jobseeker.find_by(email: email)

    if jobseeker.nil? || jobseeker.account_merge_confirmation_code != account_merge_confirmation_code
      errors.add(:account_merge_confirmation_code, :confirmation_code_mismatch, message: I18n.t("jobseekers.account_transfers.errors.account_merge_confirmation_code.confirmation_code_mismatch"))
    elsif jobseeker.account_merge_confirmation_code_generated_at < 1.hour.ago
      errors.add(:account_merge_confirmation_code, :confirmation_code_expired, message: I18n.t("jobseekers.account_transfers.errors.account_merge_confirmation_code.confirmation_code_expired"))
    end
  end
end
