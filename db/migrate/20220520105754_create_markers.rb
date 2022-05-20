class CreateMarkers < ActiveRecord::Migration[6.1]
  def change
    create_table :markers, id: :uuid do |t|
      t.belongs_to :vacancy, null: false, foreign_key: true, type: :uuid
      t.belongs_to :organisation, null: false, foreign_key: true, type: :uuid
      t.st_point :geopoint, geographic: true

      t.timestamps
    end

    add_index :markers, :geopoint, using: :gist
  end
end
