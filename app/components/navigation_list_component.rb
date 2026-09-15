#  This could be replaced by teh SLIm templatw
class NavigationListComponent < ApplicationComponent
  attr_reader :title

  def initialize(title:)
    super()

    @title = title
  end

  renders_many :anchors, lambda { |text:, href:|
    tag.li class: "navigation-list-component__anchor" do
      govuk_link_to text, href
    end
  }

  private

  def default_classes
    %w[navigation-list-component]
  end
end
