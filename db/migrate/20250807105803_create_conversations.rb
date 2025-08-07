class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations, id: :uuid do |t|
      t.references :job_application, null: false, foreign_key: true, type: :uuid
      t.string :title

      t.timestamps
    end
  end
end
