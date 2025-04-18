class TrackVacancyViewJob < ApplicationJob
  queue_as :low

  def perform(vacancy_id:, referrer_url:)
    VacancyAnalyticsService.track_visit(vacancy_id, referrer_url)
  end
end
