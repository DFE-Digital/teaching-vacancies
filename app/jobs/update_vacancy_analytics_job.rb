class UpdateVacancyAnalyticsJob < ApplicationJob
  queue_as :default

  def perform(vacancy_id, referrer)
    VacancyAnalytics.increment_view(vacancy_id, referrer)
  end
end