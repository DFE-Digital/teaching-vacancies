class Jobseekers::AccountFeedbackForm
  include ActiveModel::Model

  attr_accessor :comment, :email, :origin, :rating, :report_a_problem, :user_participation_response

  validates :report_a_problem, inclusion: { in: %w[yes no] }
  validates :comment, length: { maximum: 1200 }, if: -> { comment.present? }
  validates :email, presence: true, if: -> { user_participation_response == "interested" }
  validates :email, format: { with: Devise.email_regexp }, if: -> { email.present? }
  validates :rating, inclusion: { in: Feedback.ratings.keys }
  validates :user_participation_response, inclusion: { in: Feedback.user_participation_responses.keys }
end
