module Publishers
  class NotificationsController < ::NotificationsController
    include LoginRequired
    include ReturnPathTracking

    def notification_user
      current_publisher
    end
  end
end
