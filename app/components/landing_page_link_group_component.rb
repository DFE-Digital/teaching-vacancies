class LandingPageLinkGroupComponent < GovukComponent::Base
  def initialize(title:, list_class: "", classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @title = title
    @list_class = list_class
  end

  renders_many :links, lambda { |text, href, count:|
    # Make link text more meaningful for screenreaders
    link_content = tag.span(class: "govuk-visually-hidden") { "view #{count} " } +
                   text +
                   tag.span(class: "govuk-visually-hidden") { " jobs" }
    # Hide count from a11y tree as it's included in link text
    count_span = tag.span("aria-hidden": true) { " (#{count})" }

    tag.li { govuk_link_to(link_content, href) + count_span }
  }

  private

  def default_classes
    %w[homepage-landing-page-link-group-component]
  end
end
