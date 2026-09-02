class CreateDSIExportRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :dsi_export_runs, id: :uuid do |t|
      t.string :source, null: false
      t.integer :total_pages, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    create_table :dsi_export_run_pages, id: :uuid do |t|
      t.references :dsi_export_run, null: false, type: :uuid, foreign_key: true
      t.integer :page_number, null: false
      t.jsonb :payload, null: false

      t.timestamps

      t.index %i[dsi_export_run_id page_number], unique: true, name: "index_dsi_export_run_pages_on_run_id_and_page_number"
    end
  end
end
