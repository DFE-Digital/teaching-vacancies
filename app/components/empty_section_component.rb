class EmptySectionComponent < ApplicationComponent
  attr_reader :title

  def initialize(title: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @title = title
  end

  private

  def default_attributes
    { class: %w[empty-section-component] }
  end
end
