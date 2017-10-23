class AddUniqueIndexToSubjectName < ActiveRecord::Migration[5.1]
  def change
    add_index :subjects, :name, unique: true
  end
end
