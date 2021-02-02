class AddIndexToVacancyIdOnFeedback < ActiveRecord::Migration[6.1]
  def change
    add_index :feedbacks, :vacancy_id
  end
end
