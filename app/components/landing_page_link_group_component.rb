# Always uses locations after recent refactor that removed its other usage
# in favour of a much simpler design. Wired into LandingPage which is a much more
# complex piece of logic, which includes its own caching (when it probably shouldn't - that is normally a view concern)
# It is a hangover from when all LandingPage items were rendered individually resulting in a massive DB surge for the home page.
class LandingPageLinkGroupComponent < ApplicationComponent
  include FailSafe

  def initialize(use_locations:)
    super()

    @use_locations = use_locations
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
