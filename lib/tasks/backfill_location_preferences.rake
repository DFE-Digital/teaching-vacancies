desc "backfill uk_area for location preferences"
task backfill_location_preferences: :environment do
  JobPreferences::Location.where(uk_area: nil).find_each { |location| location.save!(touch: false) if location.valid? }
end
