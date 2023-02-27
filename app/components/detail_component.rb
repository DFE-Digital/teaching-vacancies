class DetailComponent < ApplicationComponent
  attr_reader :title

  renders_one :body

  def initialize(title: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @title = title
  end

  renders_many :actions, lambda { |action|
    tag.li(action, class: "govuk-summary-card__action")
  }

  private

  def default_classes
    %w[detail-component govuk-summary-card]
  end
end
