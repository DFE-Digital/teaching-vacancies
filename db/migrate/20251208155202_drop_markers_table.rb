class DropMarkersTable < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :markers, :vacancies
    remove_foreign_key :markers, :organisations
    drop_table :markers do
      create_table "markers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
        t.uuid "vacancy_id", null: false
        t.uuid "organisation_id", null: false
        t.geography "geopoint", limit: { srid: 4326, type: "st_point", geographic: true }
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.index %w[geopoint], name: "index_markers_on_geopoint", using: :gist
        t.index %w[organisation_id], name: "index_markers_on_organisation_id"
        t.index %w[vacancy_id], name: "index_markers_on_vacancy_id"
      end
    end
  end
end
