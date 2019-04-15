class RenameFeedbacksToVacancyPublishFeedbacks < ActiveRecord::Migration[5.2]
  def change
    rename_table :feedbacks, :vacancy_publish_feedbacks
  end
end
