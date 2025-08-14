class RemoveMessageContentColumn < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :messages, :content, type: :text }
  end
end
