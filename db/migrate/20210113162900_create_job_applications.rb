class CreateJobApplications < ActiveRecord::Migration[6.1]
  def change
    create_table :job_applications, id: :uuid do |t|
      t.integer :status

      t.timestamps
    end
  end
end
