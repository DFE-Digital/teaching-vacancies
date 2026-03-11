# frozen_string_literal: true

module Jobseekers
  class NotificationsController < ::NotificationsController
    include LoginRequired
    include ReturnPathTracking

    def mark_all_as_read
      load_notifications
      @pagy, @notifications = pagy(@raw_notifications, limit: NOTIFICATIONS_PER_PAGE)
      @notifications.mark_as_read
      redirect_to jobseekers_notifications_path
    end

    def notification_user
      current_jobseeker
    end

    private

    def mark_all_as_read_notifications_path(options = {})
      mark_all_as_read_jobseekers_notifications_path(options)
    end
  end
end
