class GeneralFeedbackForm
  include ActiveModel::Model

  attr_accessor :comment, :email, :report_a_problem, :user_participation_response, :visit_purpose, :visit_purpose_comment

  validates :report_a_problem, inclusion: { in: %w[yes no] }
  validates :comment, presence: true, length: { maximum: 1200 }
  validates :email, presence: true, if: -> { user_participation_response == "interested" }
  validates :email, email_address: true, if: -> { email.present? }
  validates :user_participation_response, inclusion: { in: Feedback.user_participation_responses.keys }
  validates :visit_purpose, inclusion: { in: Feedback.visit_purposes.keys }
  validates :visit_purpose_comment, presence: true, if: -> { visit_purpose == "other_purpose" }
  validates :visit_purpose_comment, length: { maximum: 1200 }
end
