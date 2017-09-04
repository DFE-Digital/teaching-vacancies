class CreateSchoolTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :school_types, id: :uuid do |t|
      t.string :label, null: false
    end
  end
end
