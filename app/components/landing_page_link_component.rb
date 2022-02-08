class LandingPageLinkComponent < GovukComponent::Base
  include FailSafe

  def initialize(text, href, count:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @text = text
    @href = href
    @count = count
  end
end
