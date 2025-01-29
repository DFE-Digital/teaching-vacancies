class RemovePhantomNotificationTable < ActiveRecord::Migration[7.2]
  def change
    drop_table :notifications, id: :uuid do |t|
      t.references :recipient, polymorphic: true, null: false, type: :uuid
      t.string :type, null: false
      t.jsonb :params
      t.datetime :read_at, index: true

      t.timestamps
    end
  end
end
