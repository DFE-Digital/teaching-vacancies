desc "backfill uk_area and uk_geopoint"
task backfill_uk_area: :environment do
  Subscription.find_each { |subscription| SetSubscriptionLocationDataJob.perform_later(subscription) }
end
