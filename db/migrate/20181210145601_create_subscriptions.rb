class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.string :email
      t.integer :frequency
      t.date :expires_on
      t.integer :status, default: 0
      t.jsonb :search_criteria
      t.string :reference, null: false

      t.timestamps
    end
  end
end
