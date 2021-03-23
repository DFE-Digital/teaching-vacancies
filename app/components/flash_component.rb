class FlashComponent < GovukComponent::Base
  attr_reader :variant, :message

  VARIANTS = %w[notice success warning alert].freeze

  def initialize(variant:, message:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes.merge(default_html_attributes))

    @variant = variant
    @message = message
  end

  def render?
    variant.in?(VARIANTS)
  end

  def variant_class
    "flash-component--#{variant}"
  end

  def icon_class
    "icon icon--left icon--#{variant}"
  end

  private

  def default_classes
    %w[flash-component]
  end

  def default_html_attributes
    { role: "alert", tabindex: "-1" }
  end
end
