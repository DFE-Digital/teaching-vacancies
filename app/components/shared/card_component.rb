class Shared::CardComponent < GovukComponent::Base
  include ViewComponent::SlotableV2

  renders_many :action_items, "ActionItemComponent"
  renders_many :body_items, "BodyItemComponent"
  renders_many :header_items, "HeaderItemComponent"

  attr_accessor :html_attributes, :id

  def initialize(id: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)
    @id = id
  end

  class HeaderItemComponent < ViewComponent::Base
    attr_accessor :label, :value

    def initialize(value:, label: nil)
      @label = label
      @value = value
    end

    def call
      return value unless label

      content_tag(:span, "#{label}: ", { class: "govuk-!-font-weight-bold" }) + value
    end
  end

  class BodyItemComponent < ViewComponent::Base
    attr_accessor :label, :value

    def initialize(value:, label: nil)
      @label = label
      @value = value
    end

    def call
      return value unless label

      content_tag(:span, "#{label}: ", { class: "govuk-!-font-weight-bold" }) + value
    end
  end

  class ActionItemComponent < ViewComponent::Base
    attr_accessor :text, :action, :method, :classes

    def initialize(text:, action:, method: nil, classes: nil)
      @classes = classes
      @method = method
      @action = action
      @text = text
    end

    def call
      govuk_link_to text, action, method: method, class: classes
    end
  end
end
