class AddGiasDataToColumnInSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :gias_data, :json
  end
end
