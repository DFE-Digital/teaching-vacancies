class CreateExpiredVacancyFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :expired_vacancy_feedbacks, id: :uuid do |t|
      t.uuid :vacancy_id
      t.integer :listed_elsewhere
      t.integer :hired_status

      t.timestamps
    end

    add_index :expired_vacancy_feedbacks, :vacancy_id, unique: true
  end
end
