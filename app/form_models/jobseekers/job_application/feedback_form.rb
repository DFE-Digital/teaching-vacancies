class Jobseekers::JobApplication::FeedbackForm
  include ActiveModel::Model

  attr_accessor :comment, :email, :rating, :user_participation_response

  validates :comment, length: { maximum: 1200 }, if: -> { comment.present? }
  validates :email, presence: true, if: -> { user_participation_response == "interested" }
  validates :email, email_address: true, if: -> { email.present? }
  validates :rating, inclusion: { in: Feedback.ratings.keys }
  validates :user_participation_response, inclusion: { in: Feedback.user_participation_responses.keys }
end
