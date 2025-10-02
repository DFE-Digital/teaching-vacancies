class AddAnonymiseApplicationsToVacancy < ActiveRecord::Migration[7.2]
  def change
    # Yet another boolean we might not know as we build up a vacancy
    add_column :vacancies, :anonymise_applications, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
  end
end
