class CreateLocationCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :location_categories, id: :uuid do |t|
      t.string :name
    end
    add_index :location_categories, :name
  end
end
