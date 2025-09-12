class RemoveStaleVacanciesJob < ApplicationJob
  queue_as :low

  def perform
    PublishedVacancy.where(job_title: nil).in_batches(of: 100).destroy_all
  end
end
