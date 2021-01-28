class CreateJobApplicationDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :job_application_details, id: :uuid do |t|
      t.string :details_type
      t.uuid :job_application_id
      t.jsonb :data

      t.timestamps
    end
  end
end
