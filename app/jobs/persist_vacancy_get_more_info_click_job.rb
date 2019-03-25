class PersistVacancyGetMoreInfoClickJob < ApplicationJob
  queue_as :page_view_collector

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
    VacancyGetMoreInfoClick.new(vacancy).persist!
  end
end
