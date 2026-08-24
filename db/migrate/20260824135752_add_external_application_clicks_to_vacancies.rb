class AddExternalApplicationClicksToVacancies < ActiveRecord::Migration[8.1]
  def change
    add_column :vacancies, :external_application_clicks, :integer, default: 0, null: false
  end
end
