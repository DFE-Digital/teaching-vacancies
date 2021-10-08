class AddGeolocationToVacancy < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :geolocation, :geometry, geographic: true
    add_index :vacancies, :geolocation, using: :gist
  end
end
