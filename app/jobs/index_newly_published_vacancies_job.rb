class IndexNewlyPublishedVacanciesJob < ApplicationJob
  queue_as :low

  def perform
    Vacancy.published.where(publish_on: Time.zone.today).find_each do |vacancy|
      UpdateGoogleIndexQueueJob.perform_later(Rails.application.routes.url_helpers.job_url(vacancy))
    end
  end
end
