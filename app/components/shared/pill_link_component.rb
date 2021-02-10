class Shared::PillLinkComponent < ViewComponent::Base
  attr_accessor :link_path, :link_text

  def initialize(link_path:, link_text:)
    @link_path = link_path
    @link_text = link_text
  end

  def call
    link_to link_text, link_path, class: "pill-link-component"
  end
end
