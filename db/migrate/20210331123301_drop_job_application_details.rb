class DropJobApplicationDetails < ActiveRecord::Migration[6.1]
  def change
    drop_table :job_application_details
  end
end
