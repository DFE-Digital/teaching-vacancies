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
      tag.div(class: classes, **html_attributes) do
        safe_join([
          tag.div(class: "review-component__heading__title") do
            safe_join([
              tag.h2(class: "govuk-heading-m") { title },
              edit_link,
            ].compact)
          end,
          tag.div(class: "review-component__heading__status") { content },
        ].compact)
      end
    end

    private

    def default_classes
      %w[review-component__heading]
    end

    def edit_link
      govuk_link_to text, href, aria: { label: "#{text} #{title}" } if text && href
    end
  end
end
