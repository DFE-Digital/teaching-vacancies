class AddIndexToAlertRunsRunOn < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :alert_runs, :run_on, algorithm: :concurrently
  end
end
