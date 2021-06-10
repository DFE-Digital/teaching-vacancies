class Publishers::JobListing::FeedbackForm
  include ActiveModel::Model

  attr_accessor :comment, :email, :rating, :report_a_problem, :user_participation_response

  validates :report_a_problem, inclusion: { in: %w[yes no] }
  validates :rating, inclusion: { in: Feedback.ratings.keys }
  validates :email, presence: true, if: -> { user_participation_response == "interested" }
  validates :email, format: { with: Devise.email_regexp }, if: -> { email.present? }
  validates :user_participation_response, inclusion: { in: Feedback.user_participation_responses.keys }
end
