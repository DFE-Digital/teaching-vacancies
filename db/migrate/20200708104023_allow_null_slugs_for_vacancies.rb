class AllowNullSlugsForVacancies < ActiveRecord::Migration[5.2]
  def change
    change_column_null :vacancies, :slug, true
  end
end
