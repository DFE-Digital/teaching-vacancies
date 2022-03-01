class DeviseCreateSupportUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :support_users, id: :uuid do |t|
      t.string :oid, index: true

      t.string :email
      t.string :given_name
      t.string :family_name

      t.timestamps null: false
    end
  end
end
