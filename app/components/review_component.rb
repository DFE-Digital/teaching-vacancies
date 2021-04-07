class ReviewComponent < GovukComponent::Base
  attr_reader :id, :title, :text, :href

  def initialize(id:, title:, text: nil, href: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @id = id
    @title = title
    @text = text
    @href = href
  end

  private

  def default_classes
    %w[review-component]
  end
end
