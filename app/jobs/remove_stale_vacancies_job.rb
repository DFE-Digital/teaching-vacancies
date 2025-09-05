class RemoveStaleVacanciesJob < ApplicationJob
  queue_as :low

  def perform
    # Use Vacancy here as a catch all
    Vacancy.where(job_title: nil).in_batches(of: 100).destroy_all
  end
end
