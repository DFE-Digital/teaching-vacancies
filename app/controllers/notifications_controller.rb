class NotificationsController < ApplicationController
  NOTIFICATIONS_PER_PAGE = 30

  before_action :load_notifications
  after_action :mark_notifications_as_read

  def index
    @unread_count = @raw_notifications.unread.count
    @pagy, @notifications = pagy(@raw_notifications, limit: NOTIFICATIONS_PER_PAGE)
  end

  private

  def load_notifications
    @raw_notifications = notification_user.notifications
                                          .where(created_at: (Time.current - DATA_ACCESS_PERIOD_FOR_PUBLISHERS)..)
                                          .newest_first
  end

  def mark_notifications_as_read
    @notifications.mark_as_read
  end
end
