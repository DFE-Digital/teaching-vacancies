require 'analytics'
class CacheTotalAnalyticsPageviewsQueueJob < ApplicationJob
  include ActionView::Helpers::UrlHelper
  queue_as :page_view_collector

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
    start_date = vacancy.publish_on.strftime('%Y-%m-%d')
    analytics = Analytics.new(job_path(vacancy),
                              start_date,
                              Analytics::TODAY).call

    update_total_pageviews(vacancy, analytics)
  rescue SystemExit => e
    Rails.logger.info("Sidekiq: Aborting GA total pageviews caching. Error: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Sidekiq: There was a problem caching GA total pageviews: #{e.message}")
    raise
  end

  private

  def job_path(vacancy)
    Rails.application.routes.url_helpers.job_path(vacancy)
  end

  def update_total_pageviews(vacancy, analytics)
    vacancy.total_pageviews = analytics.pageviews.to_i
    vacancy.total_pageviews_updated_at = Time.zone.now
    vacancy.save(validate: false)
  end
end
