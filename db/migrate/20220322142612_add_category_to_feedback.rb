class AddCategoryToFeedback < ActiveRecord::Migration[6.1]
  def change
    add_column :feedbacks, :category, :string
  end
end
