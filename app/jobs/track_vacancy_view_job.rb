class TrackVacancyViewJob < ApplicationJob
  queue_as :low

  def perform(vacancy_id:, referrer_url:, hostname:)
    VacancyAnalyticsService.track_visit(vacancy_id, referrer_url, hostname)
  end
end
