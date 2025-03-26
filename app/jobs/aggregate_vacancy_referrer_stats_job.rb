class AggregateVacancyReferrerStatsJob < ApplicationJob
  queue_as :default

  # Run every hour
  def perform
    VacancyAnalyticsService.aggregate_and_save_stats
  end
end