class Jobseekers::UnsubscribeFeedbackForm
  include ActiveModel::Model

  attr_accessor :reason, :other_reason, :additional_info

  validates :reason, inclusion: { in: UnsubscribeFeedback.reasons.keys }
  validates :other_reason, presence: true, if: -> { reason == "other_reason" }
  validates :additional_info, length: { maximum: 1200 }
end
