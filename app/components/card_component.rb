class CardComponent < GovukComponent::Base
  renders_one :header
  renders_one :body

  def initialize(classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)
  end

  renders_many :action_items, lambda { |link:|
    tag.div(link, class: "card-component__action")
  }

  def labelled_item(label, value)
    tag.dl do
      safe_join([
        tag.dt(label),
        tag.dd(value),
      ])
    end
  end

  private

  def default_classes
    %w[card-component]
  end
end
