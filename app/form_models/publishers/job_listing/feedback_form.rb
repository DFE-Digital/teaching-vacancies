class Publishers::JobListing::FeedbackForm < BaseForm
  attr_accessor :comment, :email, :rating, :report_a_problem, :user_participation_response, :occupation

  validates :rating, inclusion: { in: Feedback.ratings.keys }
  validates :email, presence: true, if: -> { user_participation_response == "interested" }
  validates :occupation, presence: true, if: -> { user_participation_response == "interested" }
  validates :email, "valid_email_2/email": { strict_mx: true }, if: -> { email.present? }
  validates :user_participation_response, inclusion: { in: Feedback.user_participation_responses.keys }
end
