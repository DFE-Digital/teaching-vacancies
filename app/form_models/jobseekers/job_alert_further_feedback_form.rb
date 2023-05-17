class Jobseekers::JobAlertFurtherFeedbackForm < BaseForm
  attr_accessor :comment, :email, :user_participation_response, :occupation

  validates :comment, presence: true, length: { maximum: 1200 }
  validates :email, presence: true, if: -> { user_participation_response == "interested" }
  validates :occupation, presence: true, if: -> { user_participation_response == "interested" }
  validates :email, email_address: true, if: -> { email.present? }
  validates :user_participation_response, inclusion: { in: Feedback.user_participation_responses.keys }
end
