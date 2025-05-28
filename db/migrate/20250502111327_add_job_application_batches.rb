class AddJobApplicationBatches < ActiveRecord::Migration[7.2]
  def change
    create_table :job_application_batches, id: :uuid do |t|
      t.references :vacancy, foreign_key: true, index: true, type: :uuid, null: false

      t.timestamps
    end
    create_table :batchable_job_applications, id: :uuid do |t|
      t.references :job_application_batch, foreign_key: true, index: true, type: :uuid, null: false
      t.references :job_application, type: :uuid, foreign_key: false, null: false

      t.timestamps
    end
  end
end
