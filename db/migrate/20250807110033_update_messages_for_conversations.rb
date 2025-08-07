class UpdateMessagesForConversations < ActiveRecord::Migration[7.2]
  def change
    # Add conversation_id first (nullable for now)
    safety_assured { add_reference :messages, :conversation, null: true, foreign_key: true, type: :uuid }
  end
end
