class AddAboutSchoolToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :about_school, :text
  end
end
