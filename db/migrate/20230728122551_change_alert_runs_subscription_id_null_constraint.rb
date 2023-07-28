class ChangeAlertRunsSubscriptionIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :alert_runs, :subscription_id, name: "alert_runs_subscription_id_null", validate: false
    validate_not_null_constraint :alert_runs, :subscription_id, name: "alert_runs_subscription_id_null"

    change_column_null :alert_runs, :subscription_id, false
    remove_check_constraint :alert_runs, name: "alert_runs_subscription_id_null"
  end

  def down
    change_column_null :alert_runs, :subscription_id, true
  end
end
