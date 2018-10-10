namespace :vacancies do
  desc 'Refreshes the cached pageviews for listed job vacancies'
  namespace :pageviews do
    task refresh_cache: :environment do
      Vacancy.listed.pluck(:id).each do |vacancy_id|
        CacheTotalAnalyticsPageviewsQueueJob.perform_later(vacancy_id)
        CacheWeeklyAnalyticsPageviewsQueueJob.perform_later(vacancy_id)
      end
    end
  end
end
