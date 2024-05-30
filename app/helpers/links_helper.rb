module LinksHelper
  def tracked_link_to(*, **)
    tracked_link_of_style(:govuk_link_to, *, **)
  end

  def tracked_button_link_to(*, **)
    tracked_link_of_style(:govuk_button_link_to, *, **)
  end

  def tracked_mail_to(*, **)
    tracked_link_of_style(:govuk_mail_to, *, **)
  end

  def tracked_link_of_style(method_name, *, **kwargs)
    permitted_styles = %i[
      govuk_button_link_to
      govuk_link_to
      govuk_mail_to
    ]

    raise ArgumentError, "Supports #{permitted_styles.to_sentence}" unless permitted_styles.include?(method_name)

    send(method_name, *, **kwargs.deep_merge(data: {
      controller: "tracked-link",
      action: %w[click auxclick contextmenu].map { |a| "#{a}->tracked-link#track" }.join(" "),
      "tracked-link-target": "link",
      "link-type": kwargs.delete(:link_type),
      "link-subject": kwargs.delete(:link_subject),
      "tracked-link-text": kwargs.delete(:tracked_link_text),
      "tracked-link-href": kwargs.delete(:tracked_link_href),
    }))
  end

  def open_in_new_tab_link_to(text, href, **)
    govuk_link_to(t("app.opens_in_new_tab", link_text: text), href, target: "_blank", rel: "noreferrer noopener", **)
  end

  def tracked_open_in_new_tab_link_to(text, href, **)
    tracked_link_to(t("app.opens_in_new_tab", link_text: text), href, target: "_blank", rel: "noreferrer noopener", **)
  end

  def tracked_open_in_new_tab_button_link_to(text, href, **)
    tracked_button_link_to(t("app.opens_in_new_tab", link_text: text), href, target: "_blank", rel: "noreferrer noopener", **)
  end

  def open_in_new_tab_button_link_to(text, href, **)
    govuk_button_link_to(t("app.opens_in_new_tab", link_text: text), href, target: "_blank", rel: "noopener", **)
  end

  def anon(value)
    StringAnonymiser.new(value).to_s
  end

  def school_website_link(organisation, vacancy: nil, **)
    tracked_open_in_new_tab_link_to(
      t("vacancies.listing.schools.website_link_text", organisation_name: organisation.name),
      organisation.url,
      link_type: :school_website,
      link_subject: vacancy&.id,
      **,
    )
  end

  def organisation_vacancies_link(organisation)
    open_in_new_tab_link_to(
      "#{request.host}/organisations/#{organisation.slug}",
      organisation_landing_page_path(organisation),
    )
  end

  def external_advert_link(vacancy, **)
    tracked_open_in_new_tab_button_link_to(
      t("jobs.external.link"),
      vacancy.external_advert_url,
      link_type: :external_advert_link,
      link_subject: vacancy.id,
      **,
    )
  end

  def apply_link(vacancy, **)
    tracked_open_in_new_tab_button_link_to(
      t("jobs.apply"),
      vacancy.application_link,
      "aria-label": t("jobs.aria_labels.apply_link"),
      link_type: :get_more_information,
      link_subject: vacancy.id,
      **,
    )
  end

  def ofsted_report_link(organisation, vacancy: nil, **)
    tracked_open_in_new_tab_link_to(
      t("vacancies.listing.schools.view_ofsted_report"),
      ofsted_report(organisation),
      link_type: :ofsted_report,
      link_subject: vacancy&.id,
      **,
    )
  end

  def contact_email_link(vacancy, **)
    tracked_mail_to(
      vacancy.contact_email,
      vacancy.contact_email,
      subject: t("jobs.contact_email_subject", job: vacancy.job_title),
      body: t("jobs.contact_email_body", url: job_url(vacancy)),
      link_type: :contact_email,
      link_subject: vacancy.id,
      tracked_link_text: anon(vacancy.contact_email),
      **,
    )
  end

  def application_email_link(vacancy, **)
    tracked_mail_to(
      vacancy.application_email,
      vacancy.application_email,
      subject: t("jobs.contact_email_subject", job: vacancy.job_title),
      body: t("jobs.contact_email_body", url: job_url(vacancy)),
      link_type: :application_email,
      link_subject: vacancy.id,
      tracked_link_text: anon(vacancy.application_email),
      **,
    )
  end

  def map_link(text, url, vacancy_id: nil, **)
    tracked_link_to(
      text,
      url,
      link_type: :school_website_from_map,
      link_subject: vacancy_id,
      **,
    )
  end

  def results_link(vacancy, **)
    tracked_link_to(
      vacancy.job_title,
      job_path(vacancy),
      link_type: :vacancy_visited_from_list,
      link_subject: vacancy.id,
      **,
    )
  end

  def similar_job_link(vacancy, **)
    tracked_link_to(
      vacancy.job_title,
      job_path(vacancy),
      link_type: :similar_job,
      link_subject: vacancy.id,
      **,
    )
  end

  def document_accessibility_link(vacancy, **)
    tracked_open_in_new_tab_link_to(
      t("publishers.vacancies.build.documents.accessibility_link_text"),
      "https://www.gov.uk/guidance/publishing-accessible-documents#writing-accessible-documents",
      link_type: :document_accessibility_guidance,
      link_subject: vacancy.id,
      **,
    )
  end

  def search_keyword_quick_link(type, page:, **)
    tracked_link_to(
      t("jobs.search.popular_searches.links.#{type}"),
      landing_page_path(page),
      link_type: :search_keyword_quick_link,
      **,
    )
  end

  def dsi_account_request_link(**)
    tracked_button_link_to(
      t("buttons.request_dsi_account"),
      ENV.fetch("DFE_SIGN_IN_REGISTRATION_URL", "https://profile.signin.education.gov.uk/register"),
      link_type: :dsi_account_request,
      **,
    )
  end
end
