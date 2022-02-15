class LandingPageLinkGroupComponent < GovukComponent::Base
  include FailSafe

  def initialize(title:, list_class: "", classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @title = title
    @list_class = list_class
  end

  renders_many :landing_pages, ->(slug) { LandingPageLinkComponent.new(LandingPage[slug]) }
  renders_many :location_landing_pages, ->(loc) { LandingPageLinkComponent.new(LocationLandingPage[loc]) }

  def render?
    # Rendering this component triggers a lot of expensive queries if caching is disabled (e.g. in
    # system tests or during local development). In order to render the component when developing
    # locally, enable the cache by following instructions in `config/environments/development.rb`.
    Rails.application.config.action_controller.perform_caching
  end

  private

  def default_classes
    %w[homepage-landing-page-link-group-component]
  end
end
