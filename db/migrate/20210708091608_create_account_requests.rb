class CreateAccountRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :account_requests, id: :uuid do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :organisation_name, null: false
      t.string :organisation_identifier

      t.timestamps
    end
  end
end
