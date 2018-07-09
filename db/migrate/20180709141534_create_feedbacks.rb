class CreateFeedbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :feedbacks, id: :uuid do |t|
      t.uuid :vacancy_id
      t.integer :rating
      t.string :comment

      t.timestamps
    end

    add_index :feedbacks, :vacancy_id, unique: true
  end
end
