namespace :vacancies do
  desc "Backfill vacancies with missing publish dates"
  task backfill_vacancies_with_missing_publish_dates: :environment do
    Vacancy.published.where(publish_on: nil).find_each do |v|
      # Needed to make published vacancies that got affected by a bug valid again.
      # We have no way to know when the vacancy was originally published.
      # As is sometime in the past, it is not relevant anymore.
      v.assign_attributes(publish_on: v.created_at.to_date)
      v.save!(touch: false, validate: false)
    end
  end
end
