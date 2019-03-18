class SaveJobPostingToVacancyJob < ApplicationJob
  queue_as :seed_vacancies_from_api

  def perform(vacancy); end
end
