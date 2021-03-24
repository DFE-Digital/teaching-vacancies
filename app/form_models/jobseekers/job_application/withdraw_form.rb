class Jobseekers::JobApplication::WithdrawForm
  include ActiveModel::Model

  attr_accessor :withdraw_reason

  # TODO: Update these once confirmed
  validates :withdraw_reason, inclusion: { in: %w[another_role changed_mind other] }
end
