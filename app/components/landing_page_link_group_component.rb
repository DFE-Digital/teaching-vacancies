class LandingPageLinkGroupComponent < ApplicationComponent
  include FailSafe

  def initialize(title: nil, subgroup: false, use_locations: false, list_class: "", classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @title = title
    @list_class = list_class
    @use_locations = use_locations
    @subgroup = subgroup
  end

  renders_one :title_landing_page, ->(*args, **kwargs) { build_landing_page(*args, **kwargs) }
  renders_many(:landing_pages, lambda do |*args, subgroup: false, **kwargs|
    if subgroup
      self.class.new(subgroup: true)
    else
      build_landing_page(*args, **kwargs)
    end
  end)

  def render?
    # Rendering this component triggers a lot of expensive queries if caching is disabled (e.g. in
    # system tests or during local development). In order to render the component when developing
    # locally, enable the cache by following instructions in `config/environments/development.rb`.
    Rails.application.config.action_controller.perform_caching
  end

  private

  def build_landing_page(slug, location: false)
    LandingPageLinkComponent.new(location?(location) ? LocationLandingPage[slug] : LandingPage[slug])
  end

  def list_class
    [
      @list_class,
      ("govuk-list--bullet" if title_landing_page.present?),
    ].compact.join
  end

  def default_classes
    %w[homepage-landing-page-link-group-component]
  end

  def location?(location)
    @use_locations || location
  end
end
