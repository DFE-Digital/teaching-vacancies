class LandingPageLinkGroupComponent < GovukComponent::Base
  def initialize(title:, list_class: "", classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @title = title
    @list_class = list_class
  end

  renders_many :links, "LandingPageLinkComponent"

  private

  def default_classes
    %w[homepage-landing-page-link-group-component]
  end
end
