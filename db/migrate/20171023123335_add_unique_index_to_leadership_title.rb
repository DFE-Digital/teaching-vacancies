class AddUniqueIndexToLeadershipTitle < ActiveRecord::Migration[5.1]
  def change
    add_index :leaderships, :title, unique: true
  end
end
