# frozen_string_literal: true

module Jobseekers
  class NotificationsController < ::NotificationsController
    include LoginRequired
    include ReturnPathTracking

    def notification_user
      current_jobseeker
    end
  end
end
