class CreateAlertRun < ActiveRecord::Migration[5.2]
  def change
    create_table :alert_runs, id: :uuid do |t|
      t.uuid :subscription_id, index: true
      t.date :run_on
      t.string :job_id

      t.timestamps
    end
  end
end
