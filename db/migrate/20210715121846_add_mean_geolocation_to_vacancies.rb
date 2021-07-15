class AddMeanGeolocationToVacancies < ActiveRecord::Migration[6.1]
  def up
    add_column :vacancies, :mean_geolocation, :point

    Vacancy.find_each do |vacancy|
      vacancy.set_mean_geolocation! if vacancy.respond_to?(:set_mean_geolocation!)
    end
  end

  def down
    remove_column :vacancies, :mean_geolocation, :point
  end
end
