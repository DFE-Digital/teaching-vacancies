class BannerButtonComponent < ApplicationComponent
  attr_reader :text, :href, :method, :params, :icon

  ICONS = %w[alert-white alert-blue apply check cross document green-tick info notice save saved search start success warning].freeze

  def initialize(text:, href:, method: :get, params: nil, icon: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes.merge(default_html_attributes))

    @text = text
    @href = href
    @method = method
    @params = params
    @icon = icon
  end

  def call
    button_to text, href, method: method, params: params, class: classes.append(icon_class), **html_attributes
  end

  private

  def default_classes
    %w[banner-button-component__button]
  end

  def default_html_attributes
    { form_class: "banner-button-component" }
  end

  def icon_class
    return nil if icon.blank?

    raise "invalid icon #{icon}, supported icons are #{ICONS.to_sentence}" unless icon.in?(ICONS)

    "icon icon--left icon--#{icon}"
  end
end
