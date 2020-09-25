class NotificationComponent < ViewComponent::Base
  def initialize(content:, style:, links: nil, dismiss: true, background: false, alert: 'warning')
    @content = content
    @style = style
    @links = links
    @dismiss = style == 'danger' ? false : dismiss
    @background = background
    @alert = %w[danger success].include?(style) ? false : alert
  end

  def notification_classes
    applied_class = "govuk-notification--#{@style}"
    applied_class += ' govuk-notification__background' if @background
    applied_class += " alert #{@alert}" if @alert
    applied_class
  end

  def render_title_and_body?
    @content.is_a?(Hash) && @content[:body].present?
  end
end
