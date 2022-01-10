class NotificationComponent < GovukComponent::Base
  attr_reader :notification

  def initialize(notification:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @notification = notification
  end

  private

  def default_classes
    %w[notification-component]
  end

  def unread_tag
    govuk_tag text: "new", colour: "blue"
  end
end
