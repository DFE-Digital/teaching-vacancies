module LinksHelper
  def landing_page_link_or_text(landing_page_criteria, text, match: :exact)
    lp = match == :exact ? LandingPage.matching(landing_page_criteria) : LandingPage.partially_matching(landing_page_criteria)
    return tag.span { text } unless lp

    text = match == :exact ? lp.name : landing_page_criteria.values.flatten.first
    link_text = t("landing_pages.accessible_link_text_html", name: text)
    govuk_link_to(link_text, landing_page_path(lp.slug), text_colour: true)
  end

  def tracked_link_to(text, href, **kwargs)
    govuk_link_to(text, href, **kwargs.deep_merge(data: {
      controller: "tracked-link",
      action: %w[click auxclick contextmenu].map { |a| "#{a}->tracked-link#track" }.join(" "),
      "tracked-link-target": "link",
      "link-type": kwargs.delete(:link_type),
      "link-subject": kwargs.delete(:link_subject),
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
