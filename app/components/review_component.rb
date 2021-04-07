class ReviewComponent < GovukComponent::Base
  attr_reader :id

  renders_one :heading, "HeadingComponent"
  renders_one :body

  def initialize(id:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes.merge(id: id))

    @id = id
  end

  private

  def default_classes
    %w[review-component]
  end

  class HeadingComponent < GovukComponent::Base
    attr_reader :title, :text, :href

    def initialize(title:, text: nil, href: nil, classes: [], html_attributes: {})
      super(classes: classes, html_attributes: html_attributes)

      @title = title
      @text = text
      @href = href
    end

    def call
      tag.h2(class: classes, **html_attributes) { safe_join([title, edit_link, content].compact) }
    end

    private

    def default_classes
      %w[review-component__heading govuk-heading-m]
    end

    def edit_link
      govuk_link_to text, href, aria: { label: "#{text} #{title}" } if text && href
    end
  end
end
