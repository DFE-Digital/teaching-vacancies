module Publishers
  class Publishers::BaseController < ApplicationController
    include LoginRequired

    before_action :mark_notification_as_read_if_present
    before_action :check_terms_and_conditions
    before_action :check_ats_interstitial_acknowledged

    helper_method :current_user

    def check_terms_and_conditions
      redirect_to publishers_terms_and_conditions_path unless current_publisher.accepted_terms_at?
    end

    def check_ats_interstitial_acknowledged
      return if current_publisher.nil? || current_publisher.acknowledged_ats_and_religious_form_interstitial?

      redirect_to publishers_ats_interstitial_path
    end

    private

    def mark_notification_as_read_if_present
      return unless params[:notification_id].present?
      return unless current_publisher.present?

      notification = current_publisher.notifications.find_by(id: params[:notification_id])
      notification&.mark_as_read!
    rescue StandardError => e
      Rails.logger.error("Failed to mark notification as read: #{e.message}")
    end
  end
end
