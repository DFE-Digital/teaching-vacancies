module Publishers
  class Publishers::BaseController < ApplicationController
    include LoginRequired

    before_action :mark_notification_as_read_if_present
    before_action :check_terms_and_conditions
    helper_method :current_user

    def check_terms_and_conditions
      redirect_to publishers_terms_and_conditions_path unless current_publisher.accepted_terms_at?
    end

    private

    def mark_notification_as_read_if_present
      return if params[:notification_id].blank?

      notification = current_publisher.notifications.find_by(id: params[:notification_id])
      notification&.mark_as_read
    end
  end
end
