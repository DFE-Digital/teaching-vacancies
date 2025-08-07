class CompleteMessagesConversationMigration < ActiveRecord::Migration[7.2]
  def change
    # Make conversation_id not null
    safety_assured { change_column_null :messages, :conversation_id, false }
    
    # Remove job_application_id reference
    safety_assured { remove_reference :messages, :job_application, null: false, foreign_key: true, type: :uuid }
  end
end
