class AddLastMessageAtAndHasUnreadMessagesToConversations < ActiveRecord::Migration[7.2]
  def change
    add_column :conversations, :last_message_at, :datetime
    add_column :conversations, :has_unread_messages, :boolean, default: false, null: false
  end
end
