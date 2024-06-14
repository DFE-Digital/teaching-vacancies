class Publishers::NotificationsController < Publishers::BaseController
  NOTIFICATIONS_PER_PAGE = 30

  after_action :mark_notifications_as_read

  def index
    @unread_count = notifications.unread.count
    @pagy, @notifications = pagy(notifications, items: NOTIFICATIONS_PER_PAGE)
  end

  private

  def notifications
    @notifications ||= current_publisher.noticed_events
                                        .where("created_at >= ?", Time.current - DATA_ACCESS_PERIOD_FOR_PUBLISHERS)
                                        .order(created_at: :desc)
  end

  def mark_notifications_as_read
    notifications.mark_as_read
  end
end
