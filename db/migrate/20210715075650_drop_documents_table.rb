class DropDocumentsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "name", null: false
      t.integer "size", null: false
      t.string "content_type", null: false
      t.string "download_url", null: false
      t.string "google_drive_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.uuid "vacancy_id"
      t.index ["vacancy_id"], name: "index_documents_on_vacancy_id"
    end
  end
end
