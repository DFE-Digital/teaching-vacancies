class Publishers::NotificationsController < Publishers::BaseController
  after_action :mark_notifications_as_read

  helper_method :notifications

  private

  def notifications
    @notifications ||= current_publisher.notifications.order(created_at: :desc)
  end

  def mark_notifications_as_read
    notifications.mark_as_read!
  end
end
