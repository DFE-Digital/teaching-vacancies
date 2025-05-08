class AddMonthToQualifications < ActiveRecord::Migration[7.2]
  def change
    add_column :qualifications, :month, :integer
  end
end
