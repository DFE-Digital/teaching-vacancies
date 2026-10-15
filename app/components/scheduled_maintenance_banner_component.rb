class ScheduledMaintenanceBannerComponent < ApplicationComponent
  include FailSafe

  def initialize(classes: [], html_attributes: {}, date: nil, start_time: nil, end_time: nil)
    @date = date
    @start_time = start_time
    @end_time = end_time

    super(classes: classes, html_attributes: html_attributes)
  end

  def render?
    return false unless @date.present? && @start_time.present? && @end_time.present?
    return false unless Rails.configuration.app_role.production?

    true
  end
end
