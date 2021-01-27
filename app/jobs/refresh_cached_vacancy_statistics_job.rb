class RefreshCachedVacancyStatisticsJob < ApplicationJob
  queue_as :low

  def perform
    Rails.application.load_tasks
    Rake::Task["vacancies:statistics:refresh_cache"].invoke
  end
end
