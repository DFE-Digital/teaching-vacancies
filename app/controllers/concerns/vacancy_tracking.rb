module VacancyTracking
  extend ActiveSupport::Concern

  included do
    after_action :track_vacancy_view, only: [:show]
  end

  private

  def track_vacancy_view
    return unless @vacancy&.id

    # Track asynchronously to not impact response time
    TrackVacancyViewJob.perform_later(
      vacancy_id: @vacancy.id,
      referrer_url: request.referer,
    )
  end
end
