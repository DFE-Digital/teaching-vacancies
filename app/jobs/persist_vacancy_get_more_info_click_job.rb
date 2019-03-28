class PersistVacancyGetMoreInfoClickJob < ApplicationJob
  queue_as :vacancy_statistics

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
    VacancyGetMoreInfoClick.new(vacancy).persist!
  end
end
