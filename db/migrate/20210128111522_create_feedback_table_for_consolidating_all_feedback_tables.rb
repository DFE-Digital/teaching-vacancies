class CreateFeedbackTableForConsolidatingAllFeedbackTables < ActiveRecord::Migration[6.1]
  def change
    create_table :feedbacks, id: :uuid do |t|
      t.timestamps
      t.integer :feedback_type
      t.integer :rating
      t.text :comment
      t.float :recaptcha_score
      t.boolean :relevant_to_user
      t.jsonb :search_criteria
      t.uuid :job_alert_vacancy_ids, array: true
      t.integer :unsubscribe_reason
      t.text :other_unsubscribe_reason_comment
      t.string :email
      t.integer :user_participation_response
      t.integer :visit_purpose
      t.text :visit_purpose_comment
      t.uuid :job_application_id
      t.uuid :jobseeker_id
      t.uuid :publisher_id
      t.uuid :subscription_id
      t.uuid :vacancy_id
    end
  end
end
