class Jobseekers::AccountFeedbackForm < BaseForm
  attr_accessor :comment, :email, :origin_path, :rating, :report_a_problem, :user_participation_response, :occupation

  validates :report_a_problem, inclusion: { in: %w[yes no] }
  validates :comment, length: { maximum: 1200 }, if: -> { comment.present? }
  validates :email, presence: true, if: -> { user_participation_response == "interested" }
  validates :email, email_address: true, if: -> { email.present? }
  validates :occupation, presence: true, if: -> { user_participation_response == "interested" }
  validates :rating, inclusion: { in: Feedback.ratings.keys }
  validates :user_participation_response, inclusion: { in: Feedback.user_participation_responses.keys }
end
