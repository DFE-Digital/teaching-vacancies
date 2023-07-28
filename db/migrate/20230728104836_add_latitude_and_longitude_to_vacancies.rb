class AddLatitudeAndLongitudeToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :latitude, :float
    add_column :vacancies, :longitude, :float
  end
end
