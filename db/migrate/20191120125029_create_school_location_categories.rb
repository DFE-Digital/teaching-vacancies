class CreateSchoolLocationCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :school_location_categories, id: :uuid do |t|
      t.uuid :school_id
      t.uuid :location_category_id
    end
  end
end
