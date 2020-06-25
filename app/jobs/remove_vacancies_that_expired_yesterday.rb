class RemoveVacanciesThatExpiredYesterday < ApplicationJob
  queue_as :remove_vacancies_that_expired_yesterday

  def perform
    Vacancy.remove_vacancies_that_expired_yesterday!
  end
end
