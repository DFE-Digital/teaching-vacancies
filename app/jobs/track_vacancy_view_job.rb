class TrackVacancyViewJob < ApplicationJob
  queue_as :low

  def perform(vacancy_id:, referrer_url:, hostname:, params:)
    VacancyAnalyticsService.track_visit(vacancy_id, referrer_url, hostname, params)
  end
end
