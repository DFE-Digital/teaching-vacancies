class RemoveAuditAndActivities < ActiveRecord::Migration[6.1]
  def change
    drop_table :activities
    drop_table :audit_data
  end
end
