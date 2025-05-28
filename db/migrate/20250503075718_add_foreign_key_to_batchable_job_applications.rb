class AddForeignKeyToBatchableJobApplications < ActiveRecord::Migration[7.2]
  def change
    # This tabkle has just been created, so this operation will not be slow
    safety_assured { add_foreign_key :batchable_job_applications, :job_applications }
  end
end
