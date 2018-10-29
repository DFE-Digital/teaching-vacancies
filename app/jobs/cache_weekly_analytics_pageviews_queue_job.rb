require 'analytics'
class CacheWeeklyAnalyticsPageviewsQueueJob < ApplicationJob
  include ActionView::Helpers::UrlHelper
  queue_as :page_view_collector

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
    analytics = Analytics.new(job_path(vacancy),
                              Analytics::ONEWEEKAGO,
                              Analytics::TODAY).call
    update_weekly_pageviews(vacancy, analytics)
  rescue SystemExit => e
    Rails.logger.info("Sidekiq: Aborting GA weekly pageviews caching. Error: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Sidekiq: There was a problem caching GA weekly pageviews: #{e.message}")
    raise
  end

  private

  def job_path(vacancy)
    Rails.application.routes.url_helpers.job_path(vacancy)
  end

  def update_weekly_pageviews(vacancy, analytics)
    vacancy.weekly_pageviews = analytics.pageviews.to_i
    vacancy.weekly_pageviews_updated_at = Time.zone.now
    vacancy.save(validate: false)
  end
end
