class BackfillChangeJobseekersEmailType < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    backfill_column_for_type_change :jobseekers, :email
  end

  def down
    # no op
  end
end
