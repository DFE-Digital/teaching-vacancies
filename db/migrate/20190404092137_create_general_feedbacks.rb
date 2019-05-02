class CreateGeneralFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :general_feedbacks, id: :uuid do |t|
      t.integer :rating
      t.string :comment
      t.integer :visit_purpose
      t.string :visit_purpose_comment
      t.string :email

      t.timestamps
    end
  end
end
