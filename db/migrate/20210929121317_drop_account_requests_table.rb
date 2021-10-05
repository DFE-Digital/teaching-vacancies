class DropAccountRequestsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table "account_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "full_name", null: false
      t.string "email", null: false
      t.string "organisation_name", null: false
      t.string "organisation_identifier"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
  end
end
