class AuditPublishedVacancyJob < ApplicationJob
  queue_as :low

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
    row = VacancyPresenter.new(vacancy).to_row
    AuditData.create(category: :vacancies, data: row)
  end
end
