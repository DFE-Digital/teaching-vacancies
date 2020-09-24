class Jobseekers::OrganisationOverviews::SchoolComponent < Jobseekers::OrganisationOverviews::BaseComponent
  def render?
    vacancy.at_one_school?
  end

  def rows
    [{ present: true,
       th: I18n.t('schools.type'),
       td: organisation_type(organisation: organisation, with_age_range: false) },
     { present: true, th: I18n.t('schools.phase'), td: school_phase(organisation) },
     { present: true, th: I18n.t('schools.school_size'), td: school_size(organisation) },
     { present: true, th: I18n.t('schools.age_range'), td: age_range(organisation) },
     { present: ofsted_report(organisation).present?,
       th: I18n.t('schools.ofsted_report'),
       td: link_to(I18n.t('schools.view_ofsted_report'), ofsted_report(organisation), class: 'govuk-link wordwrap',
                                                                                      target: '_blank'),
       blank: I18n.t('schools.no_information') },
     { present: organisation.website.present? || organisation.url.present?,
       th: I18n.t('schools.website'),
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
