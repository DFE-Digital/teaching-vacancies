class CreateOrganisationVacancies < ActiveRecord::Migration[5.2]
  def change
    create_table :organisation_vacancies, id: :uuid do |t|
      t.uuid :organisation_id
      t.uuid :vacancy_id
    end
  end
end
