class RemovePostcodeFromMeanGeolocationToVacancies < ActiveRecord::Migration[7.0]
  def change
    remove_column :vacancies, :postcode_from_mean_geolocation, :string
  end
end
