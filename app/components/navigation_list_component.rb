class NavigationListComponent < ApplicationComponent
  attr_reader :title

  def initialize(title: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @title = title
  end

  renders_many :anchors, lambda { |text:, href:|
    tag.li class: "navigation-list-component__anchor" do
      govuk_link_to text, href
    end
  }

  private

  def default_attributes
    { class: %w[navigation-list-component] }
  end
end
