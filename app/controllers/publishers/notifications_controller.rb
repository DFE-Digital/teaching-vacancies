module Publishers
  class NotificationsController < ::NotificationsController
    include LoginRequired

    def notification_user
      current_publisher
    end
  end
end
