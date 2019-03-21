class CreateWorkingPattern < ActiveRecord::Migration[5.2]
  def change
    create_table :working_patterns, id: :uuid do |t|
      t.string :label, null: false
      t.string :slug, null: false, unique: true
    end
  end
end
