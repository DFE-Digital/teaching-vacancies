class CardComponent < GovukComponent::Base
  include ViewComponent::SlotableV2

  renders_one :header
  renders_one :body
  renders_one :actions

  def initialize(classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)
  end

  def labelled_item(label, value)
    tag.dl do
      safe_join([
        tag.dt(label, class: "card-component__item-label govuk-!-font-weight-bold"),
        tag.dd(value),
      ])
    end
  end

  private

  def default_classes
    %w[card-component]
  end
end
