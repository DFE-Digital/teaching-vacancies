class CreateBatchEmails < ActiveRecord::Migration[7.2]
  def change
    create_table :batch_emails, id: :uuid do |t|
      t.uuid :vacancy_id, null: false, index: true

      t.integer :batch_type, null: false, default: 0

      t.timestamps
    end
    create_table :batch_email_job_applications, id: :uuid do |t|
      t.uuid :batch_email_id, null: false, index: true
      t.uuid :job_application_id, null: false, index: true

      t.timestamps
    end
    add_foreign_key :batch_emails, :vacancies, validate: false
  end
end
