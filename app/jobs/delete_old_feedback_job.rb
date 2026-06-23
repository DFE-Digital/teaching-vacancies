class DeleteOldFeedbackJob < ApplicationJob
  queue_as :default

  def perform
    Feedback.where("created_at <= ?", 5.years.ago).destroy_all
  end
end
