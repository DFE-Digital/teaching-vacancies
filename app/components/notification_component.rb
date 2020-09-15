class NotificationComponent < ViewComponent::Base
  def initialize(content:, style:, dismiss: true, background: false, alert: false)
    @content = content
    @style = style
    @dismiss = style == 'danger' ? false : dismiss
    @background = background
    @alert = %w[danger success].include?(style) ? false : alert
  end

  def notification_classes
    applied_class = "govuk-notification--#{@style}"
    applied_class += ' govuk-notification__background' if @background
    applied_class += ' alert' if @alert
    applied_class
  end

  def render_title_and_body?
    @content.is_a?(Hash) && @content[:title].present? && @content[:body].present?
  end
end
