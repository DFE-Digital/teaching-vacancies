module LinkHelper
  def active_link_class(link_path)
    return "govuk-header__navigation-item govuk-header__navigation-item--active" if current_page?(link_path)

    "govuk-header__navigation-item"
  end

  def open_in_new_tab_link_to(text, href, **kwargs)
    govuk_link_to("#{text} (opens in new tab)", href, target: "_blank", rel: "noreferrer noopener", **kwargs)
  end
end
