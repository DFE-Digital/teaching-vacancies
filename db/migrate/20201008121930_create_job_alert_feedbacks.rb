class CreateJobAlertFeedbacks < ActiveRecord::Migration[6.0]
  def change
    create_table :job_alert_feedbacks, id: :uuid do |t|
      t.boolean :relevant_to_user
      t.text :comment
      t.jsonb :search_criteria
      t.uuid :vacancy_ids, array: true
      t.references :subscription, null: false, foreign_key: true, type: :uuid
    end
  end
end
