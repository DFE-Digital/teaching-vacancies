class RemoveVacanciesThatExpiredYesterday < ActiveJob::Base
  queue_as :low

  def perform
    Vacancy.remove_vacancies_that_expired_yesterday!
  end
end
