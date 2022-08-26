class AddPayScaleToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :pay_scale, :string
  end
end
