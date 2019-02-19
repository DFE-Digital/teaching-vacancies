class TrackVacancyPageView < ApplicationJob
  queue_as :low_priority

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
  end
end
