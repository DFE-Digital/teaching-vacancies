class PanelComponent < GovukComponent::Base
  attr_reader :button_text, :heading_text

  def initialize(button_text:, heading_text:, html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @button_text = button_text
    @heading_text = heading_text
  end
end
