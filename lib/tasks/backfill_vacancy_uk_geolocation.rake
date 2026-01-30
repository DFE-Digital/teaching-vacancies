desc "Backfill vacancy uk_geolocation"
task backfill_vacancy_uk_geolocation: :environment do
  Vacancy.where(uk_geolocation: nil).find_each do |v|
    v.send(:refresh_geolocation)
    v.save!(touch: false, validate: false)
  end
end
