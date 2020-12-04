class CreateSavedJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :saved_jobs, id: :uuid do |t|
      t.uuid :jobseeker_id
      t.uuid :vacancy_id

      t.timestamps
    end
  end
end
