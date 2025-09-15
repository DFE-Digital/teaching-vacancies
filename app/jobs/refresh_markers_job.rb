class RefreshMarkersJob < ApplicationJob
  def perform
    PublishedVacancy.where(expires_at: 1.week.ago..Time.current)
      .find_each { |vacancy| vacancy.markers.delete_all }
    PublishedVacancy.live.find_each(&:reset_markers)
    Sentry.capture_message("RefreshMarkersJob run successfully", level: :info)
  end
end
