class AddIndexToSchoolUrn < ActiveRecord::Migration[5.1]
  def change
    add_index :schools, :urn, unique: true
  end
end
