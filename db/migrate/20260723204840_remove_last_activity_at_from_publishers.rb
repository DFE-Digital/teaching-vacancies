class RemoveLastActivityAtFromPublishers < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :publishers, :last_activity_at, :datetime
    end
  end
end
