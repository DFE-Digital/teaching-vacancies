class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.text :content
      t.string :sender_type, null: false
      t.uuid :sender_id, null: false
      t.uuid :conversation_id, null: false
      t.timestamps
    end

    add_index :messages, :conversation_id
    add_index :messages, [:sender_type, :sender_id], name: "index_messages_on_sender"
    add_foreign_key :messages, :conversations
  end
end
