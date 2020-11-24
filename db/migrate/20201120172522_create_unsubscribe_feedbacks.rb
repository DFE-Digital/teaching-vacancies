class CreateUnsubscribeFeedbacks < ActiveRecord::Migration[6.0]
  def change
    create_table :unsubscribe_feedbacks, id: :uuid do |t|
      t.integer :reason
      t.string :other_reason
      t.text :additional_info
      t.references :subscription, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
