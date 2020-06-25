class CreateSchoolGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :school_groups, id: :uuid do |t|
      t.string :uid, null: false
      t.json :gias_data
    end
  end
end
