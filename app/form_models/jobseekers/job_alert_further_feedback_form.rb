class Jobseekers::JobAlertFurtherFeedbackForm
  include ActiveModel::Model

  attr_accessor :comment

  validates :comment, presence: true, length: { maximum: 1200 }
end
