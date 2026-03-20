# frozen_string_literal: true

module Jobseekers
  class NotificationsController < ::NotificationsController
    include LoginRequired
    include ReturnPathTracking

    def notification_user
      current_jobseeker
    end

    private

    def mark_all_as_read_notifications_path(options = {})
      mark_all_as_read_jobseekers_notifications_path(options)
    end

    def path_for_notifications_list
      jobseekers_notifications_path
    end
  end
end
