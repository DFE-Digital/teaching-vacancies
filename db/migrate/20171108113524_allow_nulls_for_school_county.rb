class AllowNullsForSchoolCounty < ActiveRecord::Migration[5.1]
  def change
    change_column_null :schools, :county, true
  end
end
