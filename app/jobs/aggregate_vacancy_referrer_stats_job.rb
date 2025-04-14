class AggregateVacancyReferrerStatsJob < ApplicationJob
  queue_as :low

  def perform
    VacancyAnalyticsService.aggregate_and_save_stats
  end
end
