class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
<<<<<<< HEAD
      t.text :content, null: false
=======
      t.text :content
>>>>>>> 7e5386bbf (Allow sending of messages)
      t.string :sender_type, null: false
      t.uuid :sender_id, null: false
      t.uuid :conversation_id, null: false
      t.timestamps
    end

    add_index :messages, :conversation_id
<<<<<<< HEAD
    add_index :messages, %i[sender_type sender_id], name: "index_messages_on_sender"
=======
    add_index :messages, [:sender_type, :sender_id], name: "index_messages_on_sender"
>>>>>>> 7e5386bbf (Allow sending of messages)
    add_foreign_key :messages, :conversations
  end
end
