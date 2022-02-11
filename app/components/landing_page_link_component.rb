class LandingPageLinkComponent < GovukComponent::Base
  attr_reader :landing_page

  def initialize(landing_page, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @landing_page = landing_page
  end

  def href
    case landing_page
    when LocationLandingPage
      location_landing_page_path(landing_page.location)
    when LandingPage
      landing_page_path(landing_page.slug)
    end
  end
end
