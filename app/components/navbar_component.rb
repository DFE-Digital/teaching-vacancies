class NavbarComponent < GovukComponent::Base
  def initialize(classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)
  end

  renders_many :items, lambda { |link_text:, aria: {}, method: :get, align: nil, path: nil|
    if link_text == :spacer
      tag.li class: "navbar-component__items-spacer", "aria-hidden": "true", "tab-index": "-1"
    else
      tag.li class: "navbar-component__navigation-item--#{align} navbar-component-#{link_text.downcase} govuk-header__navigation-item #{active_link_class(path)}" do
        link_to link_text, path, class: "govuk-header__link", method: method, aria: aria
      end
    end
  }

  private

  def active_link_class(link_path)
    if current_page?(link_path) ||
       (link_path == organisation_path && request.original_fullpath.include?("organisation/jobs")) ||
       (link_path == root_path && request.original_fullpath =~ %r{jobs[/?]}) ||
       (link_path == jobseeker_root_path && request.original_fullpath.start_with?("/jobseekers"))
      return "govuk-header__navigation-item govuk-header__navigation-item--active"
    end

    "govuk-header__navigation-item"
  end

  def default_classes
    %w[navbar-component]
  end
end
