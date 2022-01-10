class FlashComponent < GovukComponent::Base
  attr_reader :variant_name, :message

  VARIANTS = %w[notice success warning alert].freeze

  def initialize(variant_name:, message:, classes: [], html_attributes: {})
    super(classes:, html_attributes: html_attributes.merge(default_html_attributes))

    @variant_name = variant_name
    @message = message
  end

  def render?
    variant_name.in?(VARIANTS)
  end

  def variant_class
    "flash-component--#{variant_name}"
  end

  def icon_class
    "icon icon--left icon--#{variant_name}"
  end

  private

  def default_classes
    %w[flash-component]
  end

  def default_html_attributes
    { role: "alert", tabindex: "-1" }
  end
end
