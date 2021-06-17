class NavbarComponent < GovukComponent::Base
  delegate :active_link_class, to: :helpers

  def initialize(classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)
  end

  renders_many :items, lambda { |link_text:, aria: {}, method: :get, align: nil, path: nil|
    if link_text == :spacer
      tag.li class: "navbar-component__items-spacer", "aria-hidden": "true", "tab-index": "-1"
    else
      tag.li class: "navbar-component__navigation-item--#{align} govuk-header__navigation-item #{active_link_class(path)}" do
        link_to link_text, path, class: "govuk-header__link", method: method, aria: aria
      end
    end
  }

  private

  def default_classes
    %w[navbar-component]
  end
end
