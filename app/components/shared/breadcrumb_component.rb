class Shared::BreadcrumbComponent < ViewComponent::Base
  attr_accessor :collapse_on_mobile, :crumbs

  def initialize(collapse_on_mobile:, crumbs:)
    @collapse_on_mobile = collapse_on_mobile
    @crumbs = crumbs
  end

  def breadcrumbs_class
    "govuk-!-margin-bottom-5 #{collapse_on_mobile_class}"
  end

  def collapse_on_mobile_class
    collapse_on_mobile ? "govuk-breadcrumbs--collapse-on-mobile" : ""
  end

  def crumb_link(crumb, crumb_idx)
    if crumb_idx < crumbs.count - 1
      link_to crumb[:link_text], crumb[:link_path], class: "govuk-breadcrumbs__link"
    else
      content_tag(:span, crumb[:link_text])
    end
  end
end
