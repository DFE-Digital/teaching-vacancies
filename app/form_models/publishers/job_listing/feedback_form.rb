class Publishers::JobListing::FeedbackForm
  include ActiveModel::Model

  attr_accessor :comment, :rating

  validates :rating, inclusion: { in: Feedback.ratings.keys }
end
