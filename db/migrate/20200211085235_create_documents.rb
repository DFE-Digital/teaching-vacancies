class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents, id: :uuid do |t|
      t.string :name, null: false
      t.integer :size, null: false
      t.string :content_type, null: false
      t.string :download_url, null: false
      t.string :google_drive_id, null: false

      t.timestamps
    end
  end
end
