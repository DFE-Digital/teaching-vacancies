class CreateRegions < ActiveRecord::Migration[5.1]
  def change
    create_table :regions, id: :uuid do |t|
      t.string :name, null: false, unique: true
    end
  end
end
