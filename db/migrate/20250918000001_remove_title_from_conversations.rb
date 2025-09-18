class RemoveTitleFromConversations < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :conversations, :title, :string }
  end
end