module Publishers
  class NotificationsController < ::NotificationsController
    include LoginRequired
    include ReturnPathTracking

    def notification_user
      current_publisher
    end

    private

    def mark_all_as_read_notifications_path(options = {})
      mark_all_as_read_publishers_notifications_path(options)
    end

    def path_for_notifications_list
      publishers_notifications_path
    end
  end
end
