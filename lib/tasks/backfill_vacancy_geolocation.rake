desc "Backfill vacancy geolocation"
task backfill_vacancy_geolocation: :environment do
  Vacancy.where(geolocation: nil).find_each do |v|
    v.send(:refresh_geolocation)
    v.save!(touch: false, validate: false)
  end
end
