class PersistVacancyPageViewJob < ApplicationJob
  queue_as :vacancy_statistics

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
    VacancyPageView.new(vacancy).persist!
  end
end
