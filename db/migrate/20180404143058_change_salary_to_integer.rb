class ChangeSalaryToInteger < ActiveRecord::Migration[5.1]
  def change
    change_column :pay_scales, :salary, 'integer USING CAST(salary as integer)'
  end
end
