class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :oid
      t.datetime :accepted_terms_at, null: true
    end

    add_index :users, :oid, unique: true
  end
end
