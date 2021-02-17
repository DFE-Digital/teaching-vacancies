class Shared::NotificationComponent < ViewComponent::Base
  def initialize(content:, style:,
                 links: nil,
                 dismiss: true,
                 background: false,
                 alert: "warning",
                 html_attributes: { role: "alert", tabindex: "-1" })
    @content = content
    @style = style
    @links = links
    @dismiss = style == "danger" ? false : dismiss
    @background = background
    @alert = %w[danger success].include?(style) ? false : alert
    @html_attributes = html_attributes
  end

  def notification_classes
    applied_class = "govuk-notification--#{@style}"
    applied_class += " govuk-notification__background" if @background
    applied_class += " icon icon--left icon--#{@alert}" if @alert
    applied_class
  end

  def render_title_and_body?
    @content.is_a?(Hash) && @content[:body].present?
  end
end
