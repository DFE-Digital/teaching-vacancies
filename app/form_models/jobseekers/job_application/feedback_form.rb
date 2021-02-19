class Jobseekers::JobApplication::FeedbackForm
  include ActiveModel::Model

  attr_accessor :comment, :rating

  validates :comment, length: { maximum: 1200 }, if: -> { comment.present? }
  validates :rating, inclusion: { in: Feedback.ratings.keys }
end
