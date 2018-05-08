class AddPayScaleRangeToVacancy < ActiveRecord::Migration[5.1]
  def change
    rename_column :vacancies, :pay_scale_id, :min_pay_scale_id
    add_column :vacancies, :max_pay_scale_id, :uuid
  end
end
