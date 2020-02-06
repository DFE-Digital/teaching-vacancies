class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents, id: :uuid do |t|
      t.string :name
      t.integer :size
      t.string :content_type
      t.string :download_url
      t.timestamps
    end
  end
end
