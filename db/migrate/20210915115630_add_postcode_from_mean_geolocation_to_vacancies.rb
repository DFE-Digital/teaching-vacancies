class AddPostcodeFromMeanGeolocationToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :postcode_from_mean_geolocation, :string
  end
end
