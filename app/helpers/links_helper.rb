module LinksHelper
  def tracked_link_to(*args, **kwargs)
    tracked_link_of_style(:govuk_link_to, *args, **kwargs)
  end

  def tracked_button_link_to(*args, **kwargs)
    tracked_link_of_style(:govuk_button_link_to, *args, **kwargs)
  end

  def tracked_mail_to(*args, **kwargs)
    tracked_link_of_style(:govuk_mail_to, *args, **kwargs)
  end

  def tracked_link_of_style(method_name, *args, **kwargs)
    permitted_styles = %i[
      govuk_button_link_to
      govuk_link_to
      govuk_mail_to
    ]

    raise ArgumentError, "Supports #{permitted_styles.to_sentence}" unless permitted_styles.include?(method_name)

    send(method_name, *args, **kwargs.deep_merge(data: {
      controller: "tracked-link",
      action: %w[click auxclick contextmenu].map { |a| "#{a}->tracked-link#track" }.join(" "),
      "tracked-link-target": "link",
      "link-type": kwargs.delete(:link_type),
      "link-subject": kwargs.delete(:link_subject),
      "tracked-link-text": kwargs.delete(:tracked_link_text),
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
      organisation.url,
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

  def contact_email_link(vacancy, **kwargs)
    tracked_mail_to(
      vacancy.contact_email,
      vacancy.contact_email,
      subject: t("jobs.contact_email_subject", job: vacancy.job_title),
      body: t("jobs.contact_email_body", url: job_url(vacancy)),
      link_type: :contact_email,
      link_subject: anon(vacancy.id),
      tracked_link_text: anon(vacancy.contact_email),
      **kwargs,
    )
  end

  def map_link(text, url, vacancy_id: nil, **kwargs)
    tracked_link_to(
      text,
      url,
      link_type: :school_website_from_map,
      link_subject: anon(vacancy_id),
      **kwargs,
    )
  end

  def similar_job_link(vacancy, **kwargs)
    tracked_link_to(
      vacancy.job_title,
      job_path(vacancy),
      link_type: :similar_job,
      link_subject: anon(vacancy.id),
      **kwargs,
    )
  end

  def application_pack_link(vacancy, **kwargs)
    tracked_open_in_new_tab_link_to(
      t("application_pack.link_text", size: application_pack_asset_size),
      application_pack_asset_path,
      download: t("application_pack.link_download_attr"),
      link_type: :application_form_info,
      link_subject: anon(vacancy.id),
      **kwargs,
    )
  end

  def document_accessibility_link(vacancy, **kwargs)
    tracked_open_in_new_tab_link_to(
      t("publishers.vacancies.build.documents.accessibility_link_text"),
      "https://www.gov.uk/guidance/publishing-accessible-documents#writing-accessible-documents",
      link_type: :document_accessibility_guidance,
      link_subject: anon(vacancy.id),
      **kwargs,
    )
  end

  def search_keyword_quick_link(type, page:, **kwargs)
    tracked_link_to(
      t("jobs.search.popular_searches.links.#{type}"),
      landing_page_path(page),
      link_type: :search_keyword_quick_link,
      **kwargs,
    )
  end
end
