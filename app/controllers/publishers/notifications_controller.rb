module Publishers
  class NotificationsController < ::NotificationsController
    include LoginRequired
    include ReturnPathTracking

    def mark_all_as_read
      load_notifications
      @pagy, @notifications = pagy(@raw_notifications, limit: NOTIFICATIONS_PER_PAGE)
      @notifications.mark_as_read
      redirect_to publishers_notifications_path
    end

    def notification_user
      current_publisher
    end

    private

    def mark_all_as_read_notifications_path(options = {})
      mark_all_as_read_publishers_notifications_path(options)
    end
  end
end
