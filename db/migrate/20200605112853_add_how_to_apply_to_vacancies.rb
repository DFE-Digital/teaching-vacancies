class AddHowToApplyToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :how_to_apply, :text
  end
end
