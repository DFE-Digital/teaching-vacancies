class AggregateVacancyReferrerStatsJob < ApplicationJob
  queue_as :low

  def perform
    VacancyAnalyticsService.aggregate_and_save_stats Redis.new(url: Rails.configuration.redis_queue_url)
  end
end
