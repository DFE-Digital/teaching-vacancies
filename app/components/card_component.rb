class CardComponent < GovukComponent::Base
  include ViewComponent::SlotableV2

  renders_one :header
  renders_one :body
  renders_one :actions

  def initialize(classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)
  end

  def labelled_item(label, value)
    tag.span(label, class: "card-component__item-label govuk-!-font-weight-bold") + value
  end

  def item_with_hidden_text(value, hidden_text_pre: nil, hidden_text_post: nil)
    tag.span(hidden_text_pre, class: "govuk-visually-hidden") + value + tag.span(hidden_text_post, class: "govuk-visually-hidden")
  end

  private

  def default_classes
    %w[card-component]
  end
end
