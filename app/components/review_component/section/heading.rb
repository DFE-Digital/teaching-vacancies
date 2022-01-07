class ReviewComponent::Section::Heading < GovukComponent::Base
  def initialize(title:, link_to: [], classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @title = title
    @text, @href = link_to
  end

  private

  attr_reader :title, :text, :href

  def default_classes
    %w[review-component__section__heading]
  end

  def edit_link
    govuk_link_to text, href, aria: { label: "#{text} #{title}" }, classes: "govuk-!-display-none-print" if text && href
  end
end
