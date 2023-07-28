namespace :vacancies do
  desc "Populate location"
  task populate_lat_and_long: :environment do
    vacancies = Vacancy.where.not(geolocation: nil)

    vacancies.each do |vacancy|
      # cannot add lat and long if there are multiple geolocations
      next if vacancy.geolocation.class == RGeo::Geographic::SphericalMultiPointImpl

      vacancy.update(latitude: vacancy.geolocation.latitude, longitude: vacancy.geolocation.longitude)
    end
  end
end