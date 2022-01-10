class StepsComponent < GovukComponent::Base
  attr_reader :title

  def initialize(title: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @title = title
  end

  renders_many :steps, lambda { |label:, current: false, completed: false|
    tag.li(class: step_class(current, completed)) { tag.h3(class: "govuk-heading-s") { label } }
  }

  def step_class(current, completed)
    return "steps-component__step steps-component__step--current" if current
    return "steps-component__step steps-component__step--completed" if completed

    "steps-component__step"
  end

  private

  def default_classes
    %w[steps-component]
  end
end
