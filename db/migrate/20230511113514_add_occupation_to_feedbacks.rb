class AddOccupationToFeedbacks < ActiveRecord::Migration[7.0]
  def change
    add_column :feedbacks, :occupation, :text
  end
end
