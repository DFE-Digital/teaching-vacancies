class PersistVacancyGetMoreInfoClickJob < ApplicationJob
  queue_as :low

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
    VacancyGetMoreInfoClick.new(vacancy).persist!
  end
end
