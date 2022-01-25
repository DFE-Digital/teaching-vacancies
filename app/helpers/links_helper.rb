module LinksHelper
  def tracked_link_to(text, href, **kwargs)
    govuk_link_to(text, href, **kwargs.deep_merge(data: {
      controller: "tracked-link",
      action: %w[click auxclick contextmenu].map { |a| "#{a}->tracked-link#track" }.join(" "),
      "tracked-link-target": "link",
      "link-type": kwargs[:link_type],
      "link-subject": kwargs[:link_subject],
    }))
  end

  def open_in_new_tab_link_to(text, href, **kwargs)
    govuk_link_to("#{text} (opens in new tab)", href, target: "_blank", rel: "noreferrer noopener", **kwargs)
  end

  def tracked_open_in_new_tab_link_to(text, href, **kwargs)
    tracked_link_to("#{text} (opens in new tab)", href, target: "_blank", rel: "noreferrer noopener", **kwargs)
  end

  def open_in_new_tab_button_link_to(text, href, **kwargs)
    govuk_button_link_to("#{text} (opens in new tab)", href, target: "_blank", rel: "noopener", **kwargs)
  end
end
