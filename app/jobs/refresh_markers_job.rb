class RefreshMarkersJob < ApplicationJob
  def perform
    Vacancy.where(expires_at: 1.week.ago..Time.current)
           .find_each { |vacancy| vacancy.markers.delete_all }
    Vacancy.live.find_each(&:reset_markers)
    Sentry.capture_message("RefreshMarkersJob run successfully", level: :info)
  end
end
