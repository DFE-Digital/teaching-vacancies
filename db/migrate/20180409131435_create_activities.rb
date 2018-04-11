# Migration responsible for creating a table with activities
class CreateActivities < ActiveRecord::Migration[5.1]
  # Create table
  def self.up
    create_table :activities do |t|
      t.uuid  :trackable_id
      t.string  :trackable_type

      t.string :session_id

      t.string  :key
      t.text    :parameters

      t.uuid :owner_id
      t.string :owner_type

      t.uuid :recipient_id
      t.string :recipient_type

      t.timestamps
    end

    add_index :activities, [:trackable_id, :trackable_type]
    add_index :activities, [:owner_id, :owner_type]
    add_index :activities, [:recipient_id, :recipient_type]
  end
  # Drop table
  def self.down
    drop_table :activities
  end
end
