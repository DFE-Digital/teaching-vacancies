class Shared::CardComponent < GovukComponent::Base
  include ViewComponent::SlotableV2

  attr_accessor :html_attributes, :id

  def initialize(id: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)
    @id = id
  end

  renders_many :action_items, ->(action:) { action }

  renders_many :body_items, ->(value:, label: "") { item(value, label) }

  renders_many :header_items, ->(value:, label: "") { item(value, label) }

  def item(value, label)
    return value unless label

    content_tag(:span, "#{label}: ", { class: "govuk-!-font-weight-bold" }) + value
  end
end
