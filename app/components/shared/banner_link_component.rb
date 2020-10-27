class Shared::BannerLinkComponent < ViewComponent::Base
  attr_accessor :icon_class, :link_method, :link_path, :link_text

  def initialize(icon_class:, link_method:, link_path:, link_text:)
    @icon_class = icon_class
    @link_method = link_method
    @link_path = link_path
    @link_text = link_text
  end

  def call
    link_to link_path, method: link_method, class: "banner-link banner-link--#{icon_class}" do
      content_tag(:div, link_text, class: 'banner-link__text')
    end
  end
end
