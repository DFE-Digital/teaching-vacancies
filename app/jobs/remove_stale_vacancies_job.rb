class RemoveStaleVacanciesJob < ActiveJob::Base
  queue_as :low

  def perform
    Vacancy.where(job_title: nil).in_batches(of: 100).destroy_all
  end
end
