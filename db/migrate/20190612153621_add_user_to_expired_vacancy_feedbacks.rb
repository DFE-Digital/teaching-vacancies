class AddUserToExpiredVacancyFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :expired_vacancy_feedbacks, :user_id, :uuid
    add_index :expired_vacancy_feedbacks, :user_id
  end
end
