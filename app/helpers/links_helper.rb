module LinksHelper
  def tracked_link_to(*args, **kwargs)
    tracked_link_of_style(:govuk_link_to, *args, **kwargs)
  end

  def tracked_button_link_to(*args, **kwargs)
    tracked_link_of_style(:govuk_button_link_to, *args, **kwargs)
  end

  def tracked_link_of_style(method_name, *args, **kwargs)
    raise ArgumentError, "Supports :govuk_link_to and :govuk_button_link_to" unless %i[govuk_link_to govuk_button_link_to].include?(method_name)

    send(method_name, *args, **kwargs.deep_merge(data: {
      controller: "tracked-link",
      action: %w[click auxclick contextmenu].map { |a| "#{a}->tracked-link#track" }.join(" "),
      "tracked-link-target": "link",
      "link-type": kwargs.delete(:link_type),
      "link-subject": kwargs.delete(:link_subject),
    }))
  end

  def open_in_new_tab_link_to(text, href, **kwargs)
    govuk_link_to(t("app.opens_in_new_tab", link_text: text), href, target: "_blank", rel: "noreferrer noopener", **kwargs)
  end

  def tracked_open_in_new_tab_link_to(text, href, **kwargs)
    tracked_link_to(t("app.opens_in_new_tab", link_text: text), href, target: "_blank", rel: "noreferrer noopener", **kwargs)
  end

  def tracked_open_in_new_tab_button_link_to(text, href, **kwargs)
    tracked_button_link_to(t("app.opens_in_new_tab", link_text: text), href, target: "_blank", rel: "noreferrer noopener", **kwargs)
  end

  def open_in_new_tab_button_link_to(text, href, **kwargs)
    govuk_button_link_to(t("app.opens_in_new_tab", link_text: text), href, target: "_blank", rel: "noopener", **kwargs)
  end

  def anon(value)
    StringAnonymiser.new(value).to_s
  end

  def school_website_link(organisation, vacancy: nil, **kwargs)
    tracked_open_in_new_tab_link_to(
      t("schools.website_link_text", organisation_name: organisation.name),
      organisation.website.presence || organisation.url,
      link_type: :school_website,
      link_subject: anon(vacancy&.id),
      **kwargs,
    )
  end

  def apply_link(vacancy, **kwargs)
    tracked_open_in_new_tab_button_link_to(
      t("jobs.apply"),
      vacancy.application_link,
      "aria-label": t("jobs.aria_labels.apply_link"),
      link_type: :get_more_information,
      link_subject: anon(vacancy.id),
      **kwargs,
    )
  end

  def ofsted_report_link(organisation, vacancy: nil, **kwargs)
    tracked_open_in_new_tab_link_to(
      t("schools.view_ofsted_report"),
      ofsted_report(organisation),
      link_type: :ofsted_report,
      link_subject: anon(vacancy&.id),
      **kwargs,
    )
  end
end
