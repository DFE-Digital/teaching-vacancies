class CreateApiClients < ActiveRecord::Migration[7.1]
  def change
    create_table :api_clients, id: :uuid do |t|
      t.string :name, null: false
      t.string :api_key, null: false
      t.datetime :last_rotated_at, null: false

      t.timestamps
    end
  end
end
