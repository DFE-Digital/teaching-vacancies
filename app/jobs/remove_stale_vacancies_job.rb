class RemoveStaleVacanciesJob < ApplicationJob
  queue_as :remove_stale_vacancies

  def perform
    Vacancy.where(job_title: nil).in_batches(of: 100).destroy_all
  end
end
