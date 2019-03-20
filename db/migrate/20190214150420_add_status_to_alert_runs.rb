class AddStatusToAlertRuns < ActiveRecord::Migration[5.2]
  def change
    add_column :alert_runs, :status, :integer, default: 0
  end
end
