class AddCodeSalaryAndYearToPayScale < ActiveRecord::Migration[5.1]
  def change
    add_column :pay_scales, :code, :string
    add_column :pay_scales, :salary, :string
    add_column :pay_scales, :expires_at, :date
  end
end
