class LandingPageLinkComponent < GovukComponent::Base
  include LinksHelper

  attr_reader :landing_page

  def initialize(landing_page, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @landing_page = landing_page
  end

  private

  def href
    case landing_page
    when LocationLandingPage
      location_landing_page_path(landing_page.location)
    when LandingPage
      landing_page_path(landing_page.slug)
    end
  end

  def landing_page_link
    tracked_link_to(
      t("landing_pages.accessible_link_text_with_count_html", name: @landing_page.name, count: @landing_page.count),
      href,
      link_type: :search_keyword_quick_link,
    )
  end
end
