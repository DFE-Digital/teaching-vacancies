class RemovePayScales < ActiveRecord::Migration[5.2]
  def change
    remove_column :vacancies, :min_pay_scale_id
    remove_column :vacancies, :max_pay_scale_id
  end
end
