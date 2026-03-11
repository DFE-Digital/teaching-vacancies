module Jobseekers
  class BaseController < ApplicationController
    include ReturnPathTracking
    include LoginRequired

    before_action :mark_notification_as_read_if_present

    private

    def mark_notification_as_read_if_present
      return if params[:notification_id].blank?

      notification = current_jobseeker.notifications.find_by(id: params[:notification_id])
      notification&.mark_as_read!
    end
  end
end
