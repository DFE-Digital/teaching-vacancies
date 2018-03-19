class AddApplicationLinkToVacancy < ActiveRecord::Migration[5.1]
  def change
    add_column :vacancies, :application_link, :string
  end
end
