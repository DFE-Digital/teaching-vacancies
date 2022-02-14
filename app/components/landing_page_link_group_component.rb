class LandingPageLinkGroupComponent < GovukComponent::Base
  include FailSafe

  def initialize(title:, list_class: "", classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @title = title
    @list_class = list_class
  end

  renders_many :landing_pages, ->(slug) { LandingPageLinkComponent.new(LandingPage[slug]) }
  renders_many :location_landing_pages, ->(loc) { LandingPageLinkComponent.new(LocationLandingPage[loc]) }

  private

  def default_classes
    %w[homepage-landing-page-link-group-component]
  end
end
