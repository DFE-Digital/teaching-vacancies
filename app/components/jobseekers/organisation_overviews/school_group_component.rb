class Jobseekers::OrganisationOverviews::SchoolGroupComponent < Jobseekers::OrganisationOverviews::BaseComponent
  def render?
    vacancy.central_office?
  end

  def rows
    [{ present: true, th: I18n.t('school_groups.type'), td: organisation.group_type },
     { present: organisation.website.present? || organisation.url.present?,
       th: I18n.t('school_groups.website'),
       td: link_to(I18n.t('schools.website_link_text', organisation_name: organisation.name),
                   organisation.website.presence || organisation.url,
                   class: 'govuk-link link-wrap', target: '_blank') },
     { present: vacancy.contact_email.present?,
       th: I18n.t('jobs.contact_email'),
       td: mail_to(vacancy.contact_email, vacancy.contact_email, class: 'govuk-link link-wrap',
                                                                 subject: I18n.t('jobs.contact_email_subject', job: vacancy.job_title),
                                                                 body: I18n.t('jobs.contact_email_body', url: job_url(vacancy))) },
     { present: vacancy.contact_number.present?,
       th: I18n.t('jobs.contact_number'),
       td: link_to(vacancy.contact_number, "tel:#{vacancy.contact_number}", class: 'govuk-link') }]
  end
end
