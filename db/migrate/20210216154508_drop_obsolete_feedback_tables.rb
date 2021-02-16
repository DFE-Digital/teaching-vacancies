class DropObsoleteFeedbackTables < ActiveRecord::Migration[6.1]
  def up
    drop_table :account_feedbacks
    drop_table :general_feedbacks
    drop_table :job_alert_feedbacks
    drop_table :unsubscribe_feedbacks
    drop_table :vacancy_publish_feedbacks
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
