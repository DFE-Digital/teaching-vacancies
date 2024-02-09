class AddGeolocationAndTimestampsIndexToVacancy < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :vacancies, [:geolocation, :expires_at, :publish_on], using: :gist, algorithm: :concurrently
    remove_index :vacancies, column: :geolocation, name: "index_vacancies_on_geolocation", algorithm: :concurrently
  end
end
