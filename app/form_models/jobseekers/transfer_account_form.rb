class Jobseekers::TransferAccountForm < BaseForm
  attr_accessor :email

  validates :email, presence: true
  validates :email, email_address: true, if: -> { email.present? }
end
