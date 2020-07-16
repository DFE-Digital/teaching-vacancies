class ChangeAboutSchoolFieldToAboutOrganisation < ActiveRecord::Migration[5.2]
  def change
    rename_column :vacancies, :about_school, :about_organisation
  end
end
