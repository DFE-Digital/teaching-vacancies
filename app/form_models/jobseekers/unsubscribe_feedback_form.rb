class Jobseekers::UnsubscribeFeedbackForm
  include ActiveModel::Model

  attr_accessor :comment, :other_unsubscribe_reason_comment, :unsubscribe_reason

  validates :comment, length: { maximum: 1200 }
  validates :other_unsubscribe_reason_comment, presence: true, if: -> { unsubscribe_reason == "other_reason" }
  validates :unsubscribe_reason, inclusion: { in: Feedback.unsubscribe_reasons.keys }
end
