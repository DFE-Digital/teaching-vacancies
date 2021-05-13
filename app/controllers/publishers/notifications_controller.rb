class Publishers::NotificationsController < Publishers::BaseController
  DEFAULT_NOTIFICATIONS_PER_PAGE = 30

  after_action :mark_notifications_as_read

  helper_method :notifications

  private

  def notifications
    @notifications ||= current_publisher.notifications
                                        .created_within_data_retention_period
                                        .order(created_at: :desc)
                                        .page(params[:page])
                                        .per(DEFAULT_NOTIFICATIONS_PER_PAGE)
  end

  def mark_notifications_as_read
    notifications.mark_as_read!
  end
end
