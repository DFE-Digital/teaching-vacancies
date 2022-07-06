class Publishers::NotificationsController < Publishers::BaseController
  NOTIFICATIONS_PER_PAGE = 30

  after_action :mark_notifications_as_read

  def index
    @unread_count = notifications.unread.count
    @pagy, @notifications = pagy(notifications, items: NOTIFICATIONS_PER_PAGE)
  end

  private

  def notifications
    @notifications ||= current_publisher.notifications
                                        .created_within_data_access_period
                                        .order(created_at: :desc)
  end

  def mark_notifications_as_read
    notifications.mark_as_read!
  end
end
