class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :job_application_id, null: false
      t.string :title
      t.timestamps
    end

    add_index :conversations, :job_application_id
    add_foreign_key :conversations, :job_applications
  end
end
