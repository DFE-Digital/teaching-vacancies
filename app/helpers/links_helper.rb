module LinksHelper
  def open_in_new_tab_link_to(text, href, **kwargs)
    govuk_link_to("#{text} (opens in new tab)", href, target: "_blank", rel: "noreferrer noopener", **kwargs)
  end

  def open_in_new_tab_button_link_to(text, href, **kwargs)
    govuk_button_link_to("#{text} (opens in new tab)", href, target: "_blank", rel: "noopener", **kwargs)
  end
end
