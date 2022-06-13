class DetailComponent < ApplicationComponent
  attr_reader :title

  renders_one :body
  renders_one :actions

  def initialize(title: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @title = title
  end

  private

  def default_classes
    %w[detail-component]
  end
end
