class IndexNewlyPublishedVacanciesJob < ApplicationJob
  queue_as :low

  # This job is to ensure vacancies that were created/updated before their published at date get indexed once they are published.
  def perform
    Vacancy.published.where(publish_on: Time.zone.today).find_each do |vacancy|
      UpdateGoogleIndexQueueJob.perform_later(Rails.application.routes.url_helpers.job_url(vacancy))
    end
  end
end
