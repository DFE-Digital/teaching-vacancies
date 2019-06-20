class DropExpiredVacancyFeedbacks < ActiveRecord::Migration[5.2]
  def change
    drop_table :expired_vacancy_feedbacks
  end
end
