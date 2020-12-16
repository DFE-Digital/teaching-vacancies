class CreateAccountFeedbacks < ActiveRecord::Migration[6.0]
  def change
    create_table :account_feedbacks, id: :uuid do |t|
      t.integer :rating
      t.text :suggestions
      t.references :jobseeker, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
