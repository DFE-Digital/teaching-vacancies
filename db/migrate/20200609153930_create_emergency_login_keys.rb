class CreateEmergencyLoginKeys < ActiveRecord::Migration[5.2]
  def up
    create_table :emergency_login_keys, id: :uuid do |t|
      t.datetime :not_valid_after, null: false
      t.references :user, foreign_key: true, type: :uuid

      t.timestamps
    end
  end

  def down
    drop_table :emergency_login_keys, if_exists: true, id: :uuid do |t|
      t.datetime :not_valid_after, null: false
      t.references :user, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
