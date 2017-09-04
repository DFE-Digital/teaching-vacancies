class CreateSubjects < ActiveRecord::Migration[5.1]
  def change
    create_table :subjects, id: :uuid do |t|
      t.string :name, null: false, unique: true
    end
  end
end
