class PanelComponent < GovukComponent::Base
  renders_one :body

  attr_reader :heading_text, :button_text, :panel_id

  def initialize(panel_id:, button_text:, heading_text:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @button_text = button_text
    @heading_text = heading_text
    @panel_id = panel_id
  end

  private

  def default_classes
    %w[panel-component]
  end
end
