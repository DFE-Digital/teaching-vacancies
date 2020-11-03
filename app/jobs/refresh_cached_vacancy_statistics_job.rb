class RefreshCachedVacancyStatisticsJob < ApplicationJob
  queue_as :refresh_cached_vacancy_statistics

  def perform
    Rails.application.load_tasks
    Rake::Task["vacancies:statistics:refresh_cache"].invoke
  end
end
