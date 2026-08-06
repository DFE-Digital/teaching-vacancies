class TrackVacancyViewJob < ApplicationJob
  queue_as :low

  def perform(vacancy_id:, referrer_url:, hostname:, params:)
    VacancyAnalyticsService.track_visit(Redis.new(url: Rails.configuration.redis_queue_url), vacancy_id, referrer_url, hostname, params)
  end
end
