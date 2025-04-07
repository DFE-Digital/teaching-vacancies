class IndexNewlyLiveVacanciesJob < ApplicationJob
  queue_as :low

  def perform
    Vacancy.published
           .where("publish_on = ?", Date.yesterday)
           .where("expires_at >= ?", Time.current)
           .find_each do |vacancy|
      next unless vacancy.listed?

      UpdateGoogleIndexQueueJob.perform_later(job_url(vacancy))
    end
  end
end