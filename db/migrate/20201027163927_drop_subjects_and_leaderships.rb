class DropSubjectsAndLeaderships < ActiveRecord::Migration[6.0]
  def change
    drop_table :subjects
    drop_table :leaderships
  end
end
