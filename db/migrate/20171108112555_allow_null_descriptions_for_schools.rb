class AllowNullDescriptionsForSchools < ActiveRecord::Migration[5.1]
  def change
    change_column_null :schools, :description, true
  end
end
