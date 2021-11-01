class Jobseekers::UnsubscribeFeedbackForm < BaseForm
  attr_accessor :comment, :email, :other_unsubscribe_reason_comment, :unsubscribe_reason, :user_participation_response

  validates :comment, length: { maximum: 1200 }
  validates :email, presence: true, if: -> { user_participation_response == "interested" }
  validates :email, email_address: true, if: -> { email.present? }
  validates :other_unsubscribe_reason_comment, presence: true, if: -> { unsubscribe_reason == "other_reason" }
  validates :unsubscribe_reason, inclusion: { in: Feedback.unsubscribe_reasons.keys }
  validates :user_participation_response, inclusion: { in: Feedback.user_participation_responses.keys }
end
