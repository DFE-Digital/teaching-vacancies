class AddOriginPathToFeedbacks < ActiveRecord::Migration[7.0]
  def change
    add_column :feedbacks, :origin_path, :string
  end
end
