class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :recipient, polymorphic: true, null: false, type: :uuid
      t.string :type, null: false
      t.jsonb :params
      t.datetime :read_at

      t.timestamps
    end
    add_index :notifications, :read_at
  end
end
